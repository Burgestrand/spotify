require "monitor"

module Spotify
  # The Reaper!
  #
  # Garbage collection may happen in a separate thread, and if we are
  # unfortunate enough the main thread will hold the API lock around Spotify,
  # which makes it impossible for the GC thread to obtain the lock to release
  # pointers.
  #
  # When garbage collection happens in a separate thread, it’s possible that
  # the main threads will not run until garbage collection is finished. If the
  # GC thread deadlocks, the entire application deadlocks.
  #
  # The idea is to locklessly pass pointers that need releasing to a queue. The
  # worker working the queue should be safe to acquire the API lock because
  # nobody is waiting for the working queue to ever finish.
  class Reaper
    class Node
      attr_accessor :next

      def initialize(pointer)
        @pointer = pointer
        @next = nil
      end

      def free
        Spotify.log "Node has already been freed." if @pointer.nil?
        @pointer.free
        @pointer = nil
      end
    end

    # Freeze to prevent against modification.
    EMPTY = [].freeze

    # Time to sleep between each reaping.
    IDLE_TIME = 0.2

    # The underlying Reaper thread.
    attr_reader :reaper_thread

    class << self
      # @return [Reaper] The Reaper.
      attr_accessor :instance

      # @return [Boolean] true if Reaper should terminate at exit.
      attr_accessor :terminate_at_exit
    end

    def initialize(idle_time = IDLE_TIME)
      @run = true
      @idle_time = idle_time

      @head = @tail = Node.new(nil)
      @writer_monitor = Monitor.new

      @reaper_thread = Thread.new do
        begin
          while @run
            # It is possible that tail.next will be set by the GC thread
            # after our check, but that is alright since we will wake up
            # in the next Reaping anyway and GC it!
            until @head.next.nil?
              # This is safe since the GC thread (#mark) never modifies the
              # @head, but only the @tail. If @head.next ever exists, it will
              # always exist, nobody will unset it under our feet.
              @head = @head.next
              @head.free
            end
            # mostly @head is @tail after this, unless GC runs again

            sleep(@idle_time) # support sleeping forever
          end
        ensure
          Thread.current[:exception] = exception = $!
          Spotify.log "Spotify::Reaper WAS KILLED: #{exception.inspect}!" if exception
        end
      end
    end

    # Mark a pointer for release. Thread-safe, uses no locks.
    #
    # @note YOU MUST NEVER CALL THIS YOURSELF! If you do so, you risk ending up
    #       in a deadlock with the garbage collection threads.
    #
    # @param [#free] pointer
    def mark(pointer)
      # Possible race-condition here. Don't really care.
      if reaper_thread.alive?
        Spotify.log "Spotify::Reaper#mark(#{pointer.inspect})"

        # GC should only be from one thread, but if one implementation calls
        # finalizers concurrently, or if users of Spotify calls #mark, this
        # check prevents us from chasing memory leaks.
        unless @writer_monitor.try_enter
          $stdout.puts "Writer lock is not free. This is bad; also, you are now leaking memory!"
          raise Spotify::Error, "Writer lock is already busy."
        end

        begin
          node = Node.new(pointer)
          tail, @tail = @tail, node
          tail.next = @tail
        ensure
          @writer_monitor.exit
        end

        reaper_thread.wakeup
      else
        Spotify.log "Spotify::Reaper is dead. Cannot mark (#{pointer.inspect})."
      end
    rescue => e
      # Finalizers do not show raised errors.
      Spotify.log "Spotify::Reaper#mark FAILED: #{e} #{e.message}."
      raise
    end

    # Terminate the Reaper. Will wait until the Reaper exits, or until timeout occurs.
    #
    # @param [Integer] wait_time how long to wait for reaper to exit
    # @return [Boolean] true if reaper is no longer running
    def terminate(wait_time = @idle_time)
      if wait_time.nil? or wait_time.zero?
        raise Spotify::Error, "Cannot wait forever without risk of race condition."
      end

      if reaper_thread.alive?
        Spotify.log "Spotify::Reaper terminating."
        @run = false
        reaper_thread.run
        return reaper_thread.join(wait_time)
      end

      true
    end

    # Same as #terminate, but raises an error if reaper fails to exit.
    #
    # @raise [Spotify::Error] if reaper did not exit in time
    # @see #terminate
    def terminate!(wait_time = @idle_time)
      terminate(wait_time) or raise Spotify::Error, "Spotify::Reaper did not terminate within #{wait_time} seconds."
    end

    @instance = new
    @terminate_at_exit = true
  end
end

at_exit do
  if Spotify::Reaper.terminate_at_exit
    Spotify::Reaper.instance.terminate(1)
  end
end
