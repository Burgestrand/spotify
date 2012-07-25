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
  end
end
