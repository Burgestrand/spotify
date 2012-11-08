module Spotify
  # A custom data type for Spotify image IDs.
  #
  # It will convert strings to image ID pointers when handling
  # values from Ruby to C, and it will convert pointers to Ruby
  # strings when handling values from C to Ruby.
  module ImageID
    extend FFI::DataConverter
    native_type FFI::Type::POINTER

    class << self
      # @return [Integer] bytesize of image ID pointers.
      def size
        20
      end

      # Given a string, convert it to an image ID pointer.
      #
      # @param [#to_str, nil] value image id as a string
      # @param ctx
      # @return [FFI::Pointer] pointer to the image ID
      def to_native(value, ctx)
        value && begin
          value = value.to_str

          if value.bytesize != size
            raise ArgumentError, "image id bytesize must be #{size}, was #{value.bytesize}"
          end

          pointer = FFI::MemoryPointer.new(:char, size)
          pointer.write_string(value)
        end
      end

      # Given a pointer, read a {.size}-byte image ID from it.
      #
      # @param [FFI::Pointer] value
      # @param ctx
      # @return [String, nil] the image ID as a string, or nil
      def from_native(value, ctx)
        value.read_string(size) unless value.null?
      end

      # @see NulString.reference_required?
      def reference_required?
        true
      end
    end
  end
end
