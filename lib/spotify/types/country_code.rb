module Spotify
  # A type for converting a country code to an int, and vice versa.
  module CountryCode
    extend FFI::DataConverter
    native_type FFI::Type::INT
    PACK_FORMAT = "s>"

    class << self
      # Given a two-char country code, encodes it to an integer.
      #
      # @param [String, nil] country_code
      # @param ctx
      # @return [Integer] country code as int
      def to_native(country_code, ctx)
        country_code.unpack(PACK_FORMAT)[0]
      end

      # Given a two-char country code as int, decodes it to a string.
      #
      # @param [Integer] country_code
      # @param ctx
      # @return [String] country code as string
      def from_native(country_code, ctx)
        [country_code].pack(PACK_FORMAT)
      end
    end
  end
end
