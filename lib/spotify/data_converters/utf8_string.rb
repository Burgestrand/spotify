module Spotify
  # A UTF-8 FFI type, making sure all strings are UTF8 in and out.
  #
  # Given an ingoing (ruby to C) string, it will make sure the string
  # is in UTF-8 encoding. An outgoing (C to Ruby) will be assumed to
  # actually be in UTF-8, and force-encoded as such.
  module UTF8String
    extend FFI::DataConverter
    native_type FFI::Type::STRING

    class << self
      # Given a value, encodes it to UTF-8 no matter what.
      #
      # @note if the value is already in UTF-8, ruby does nothing
      # @note if the given value is falsy, default behaviour is used
      #
      # @param [String, nil] value
      # @param ctx
      # @return [String] value, but in UTF-8 if it wasn’t already
      def to_native(value, ctx)
        value && value.encode('UTF-8')
      end

      # Given an original string, assume it is in UTF-8.
      #
      # @note NO error checking is made, the string is just forced to UTF-8
      # @param [String] value can be in any encoding
      # @param ctx
      # @return [String] value, but with UTF-8 encoding
      def from_native(value, ctx)
        value && value.force_encoding('UTF-8')
      end
    end
  end
end
