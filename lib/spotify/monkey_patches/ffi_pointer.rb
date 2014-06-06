require "ffi"

# @see http://github.com/ffi/ffi
module FFI
  # Superclass for FFI::Pointer.
  class AbstractMemory
    unless method_defined?(:read_size_t)
      type = FFI.find_type(:size_t)
      type, _ = FFI::TypeDefs.find do |(name, t)|
        method_defined? "read_#{name}" if t == type
      end

      if type.nil?
        raise "Missing method to read a size_t from #{klass}"
      end

      alias_method(:read_size_t, "read_#{type}")
      alias_method(:write_size_t, "write_#{type}")
    end
  end
end
