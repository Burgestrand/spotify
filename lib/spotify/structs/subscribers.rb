module Spotify
  # Spotify::Struct for Subscribers of a Playlist.
  #
  # Memory looks like this:
  #   00 00 00 00 <- count of subscribers
  #   00 00 00 00 <- pointer to subscriber 1
  #   …… …… …… ……
  #   00 00 00 00 <- pointer to subscriber n
  #
  # @attr [Fixnum] count
  # @attr [Array<Pointer<String>>] subscribers
  class Subscribers < Spotify::Struct
    include Enumerable

    class << self
      def release(pointer)
        unless pointer.null?
          pointer = type_class.new(pointer)
          $stderr.puts "Spotify.playlist_subscribers_free(#{pointer.inspect})" if $DEBUG
          Spotify.playlist_subscribers_free(pointer)
        end
      end
    end

    layout :count => :uint,
           :subscribers => [UTF8StringPointer, 0] # array of pointers to strings

    # Redefined, as the layout of the Struct can only be determined
    # at run-time.
    #
    # @param [FFI::Pointer, Integer] pointer_or_count
    def initialize(pointer_or_count)
      count = if pointer_or_count.is_a?(FFI::Pointer)
        if pointer_or_count.null?
          0
        else
          pointer_or_count.read_uint
        end
      else
        pointer_or_count
      end

      layout  = [:count, :uint]
      layout += [:subscribers, [UTF8StringPointer, count]]

      if pointer_or_count.is_a?(FFI::Pointer)
        super(pointer_or_count, *layout)
      else
        super(nil, *layout)
        self[:count] = count
      end
    end

    # Yields every subscriber as a UTF8-encoded string.
    #
    # @yield [subscriber]
    # @yieldparam [String] subscriber
    def each
      return enum_for(__method__) { count } unless block_given?
      count.times { |index| yield self[:subscribers][index] }
    end

    private

    # @return [Integer] number of subscribers in the struct.
    def count
      if null?
        0
      else
        self[:count]
      end
    end
  end
end
