module Spotify
  # A custom data type for Spotify image IDs.
  #
  # It will convert strings to image ID pointers when handling
  # values from Ruby to C, and it will convert pointers to Ruby
  # strings when handling values from C to Ruby.
  module ImageID
    extend FFI::DataConverter
    native_type FFI::Type::POINTER

    # Given a string, convert it to an image ID pointer.
    #
    # @param [String] value image id as a string
    # @param ctx
    # @return [FFI::Pointer] pointer to the image ID
    def self.to_native(value, ctx)
      pointer = if value
        if value.bytesize != 20
          raise ArgumentError, "image id bytesize must be 20, was #{value.bytesize}"
        end

        pointer = FFI::MemoryPointer.new(:char, 20)
        pointer.write_string(value.to_s)
      end

      super(pointer, ctx)
    end

    # Given a pointer, read a 20-byte image ID from it.
    #
    # @param [FFI::Pointer] value
    # @param ctx
    # @return [String, nil] the image ID as a string, or nil
    def self.from_native(value, ctx)
      value.read_string(20) unless value.null?
    end

    # @see NulString.reference_required?
    def self.reference_required?
      true
    end
  end
end
