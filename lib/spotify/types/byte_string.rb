module Spotify
  module ByteString
    extend FFI::DataConverter
    native_type FFI::Type::POINTER

    class << self
      # Given either a String or nil, make an actual FFI::Pointer
      # of that value, without an ending NULL-byte.
      #
      # @param [#to_str, nil] value
      # @param ctx
      # @return [FFI::Pointer]
      def to_native(value, ctx)
        value && begin
          value = value.to_str

          pointer = FFI::MemoryPointer.new(:char, value.bytesize)
          pointer.write_string(value)
        end
      end

      # @see NulString.reference_required?
      def reference_required?
        true
      end
    end
  end
end
