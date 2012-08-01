module Spotify
  # The NULString is used to allow you to assign struct fields
  # with regular ruby strings. Usually, it would raise an error.
  #
  # Keep in mind this implementation is unsafe to use on Rubinius
  # as long as it ignores the .reference_required? indication.
  module NULString
    extend FFI::DataConverter
    native_type FFI::Type::POINTER

    def self.to_native(value, ctx)
      # This is alright since MRI and JRuby both
      # keep a strong reference to this pointer
      # inside the struct where it’s been assigned.
      return FFI::Pointer::NULL if value.nil?

      unless value.respond_to?(:to_str)
        raise TypeError, "#{value.inspect} cannot be converted to string"
      end

      FFI::MemoryPointer.from_string(value.to_str)
    end

    def self.from_native(value, ctx)
      if value.null?
        nil
      else
        value.read_string
      end
    end

    # Used by FFI::StructLayoutField to know if this field
    # requires the reference to be maintained by FFI. If we
    # return false here, the MemoryPointer from to_native
    # will be garbage collected before the struct.
    def self.reference_required?
      true
    end
  end
end
