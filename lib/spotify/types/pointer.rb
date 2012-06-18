module Spotify
  # The Pointer is a kind of AutoPointer specially tailored for Spotify
  # objects, that releases the raw pointer on GC.
  class Pointer < FFI::AutoPointer
    # Raised when #releaser_for is given an invalid type.
    class InvalidTypeError < StandardError
    end

    class << self
      # Create a proc that will accept a pointer of a given type and
      # release it with the correct function if it’s not null.
      #
      # @raise [InvalidTypeError] when given an invalid type
      # @param [Symbol] type
      # @return [Proc]
      def releaser_for(type)
        unless Spotify.respond_to?(:"#{type}_release!")
          raise InvalidTypeError, "#{type} is not a valid Spotify type"
        end

        lambda do |pointer|
          $stdout.puts "Spotify::#{type}_release!(#{pointer})" if $DEBUG
          Spotify.send(:"#{type}_release!", pointer) unless pointer.null?
        end
      end

      # Checks an object by pointer kind and type.
      #
      # @param [Object] object
      # @param [Symbol] type
      # @return [Boolean] true if object is a spotify pointer and of correct type
      def typechecks?(object, type)
        object.is_a?(Spotify::Pointer) && (object.type == type.to_s)
      end
    end

    # @return [Symbol] type
    attr_reader :type

    # Initialize a Spotify pointer, which will automatically decrease
    # the reference count of it’s pointer when garbage collected.
    #
    # @param [FFI::Pointer] pointer
    # @param [#to_s] type session, link, etc
    # @param [Boolean] add_ref will increase refcount by one if true
    def initialize(pointer, type, add_ref)
      super pointer, self.class.releaser_for(@type = type.to_s)

      unless pointer.null?
        Spotify.send(:"#{type}_add_ref!", pointer)
      end if add_ref
    end

    # @return [String] representation of the spotify pointer
    def to_s
      "<#{self.class} address=0x#{address.to_s(16)} type=#{type}>"
    end
  end
end
