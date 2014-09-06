# Fix for https://github.com/jruby/jruby/issues/1954
unless FFI::Enums.method_defined?(:default)
  FFI::Enums.send(:attr_accessor, :default)
end
