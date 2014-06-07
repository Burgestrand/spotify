module Spotify
  # The NULString is used to allow you to assign struct fields
  # with regular ruby strings. Usually, it would raise an error.
  #
  # Keep in mind this implementation is unsafe to use on Rubinius
  # as long as it ignores the .reference_required? indication.
  module UTF8StringPointer
    extend FFI::DataConverter
    native_type FFI::Type::POINTER

    class << self
      # Given either a String or nil, make an actual FFI::Pointer
      # of that value.
      #
      # @param [#to_str, nil] value
      # @param ctx
      # @return [FFI::Pointer]
      def to_native(value, ctx)
        value && FFI::MemoryPointer.from_string(value.to_str.encode(Encoding::UTF_8))
      end

      # Given a pointer, read out it’s string.
      #
      # @param [FFI::Pointer] value
      # @param ctx
      # @return [String, nil]
      def from_native(value, ctx)
        value.read_string.force_encoding(Encoding::UTF_8) unless value.null?
      end

      # Used by FFI::StructLayoutField to know if this field
      # requires the reference to be maintained by FFI. If we
      # return false here, the MemoryPointer from to_native
      # will be garbage collected before the struct.
      def reference_required?
        true
      end
    end
  end
end
