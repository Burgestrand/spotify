module Spotify
  module NULString
    extend FFI::DataConverter
    native_type FFI::Type::POINTER

    def self.to_native(value, ctx)
      # This is alright since MRI and JRuby both
      # keep a strong reference to this pointer
      # inside the struct where it’s been assigned.
      FFI::MemoryPointer.from_string(value.to_s)
    end

    def self.from_native(value, ctx)
      if value.null?
        ""
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
