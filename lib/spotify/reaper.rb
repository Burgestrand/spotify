require 'atomic'

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
      @queue = Atomic.new(EMPTY)

      @reaper_thread = Thread.new do
        begin
          while @run
            pointers = @queue.swap(EMPTY)
            pointers.each(&:free)
            sleep(@idle_time)
          end
        ensure
          Thread.current[:exception] = exception = $!
          Spotify.log "Spotify::Reaper WAS KILLED: #{exception.inspect}!" if exception
        end
      end
    end

    # Mark a pointer for release. Thread-safe, uses no locks.
    #
    # @note This is called from the GC thread, and as such it is very important
    # that this never waits for a lock held by the main Ruby thread, or we will
    # get deadlocks here.
    #
    # @param [#free] pointer
    def mark(pointer)
      # Possible race-condition here. Don't really care.
      if reaper_thread.alive?
        Spotify.log "Spotify::Reaper#mark(#{pointer.inspect})"

        @queue.update do |queue|
          # this needs to be able to run without side-effects as many
          # times as may be needed
          [pointer].unshift(*queue)
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
        unless reaper_thread.join(wait_time)
          Spotify.log "Spotify::Reaper did not terminate within #{wait_time}."
          return false
        end
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
