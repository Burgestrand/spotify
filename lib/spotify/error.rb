module Spotify
  # A generic error class for Spotify errors.
  class Error < StandardError
    class << self
      # Explain a Spotify error with a descriptive message.
      #
      # @note this method calls the API directly, since the
      #       underlying API call is considered thread-safe.
      #
      # @param [Symbol, Integer] error
      # @return [String] a decriptive string of the error
      def explain(error)
        error, symbol = disambiguate(error)

        message = []
        message << "[#{symbol.to_s.upcase}]"
        message << Spotify::API.error_message(error)
        message << "(#{error})"

        message.join(' ')
      end

      # Given a number or a symbol, find both the symbol and the error
      # number it represents.
      #
      # @example given an integer
      #   Spotify::Error.disambiguate(0) # => [0, :ok]
      #
      # @example given a symbol
      #   Spotify::Error.disambiguate(:ok) # => [0, :ok]
      #
      # @example given bogus
      #   Spotify::Error.disambiguate(:bogus) # => [-1, nil]
      #
      # @param [Symbol, Fixnum] error
      # @return [[Fixnum, Symbol]] (error code, error symbol)
      def disambiguate(error)
        @enum ||= Spotify.enum_type(:error)

        if error.is_a? Symbol
          error = @enum[symbol = error]
        else
          symbol = @enum[error]
        end

        if error.nil? || symbol.nil?
          [-1, nil]
        else
          [error, symbol]
        end
      end
    end

    # Overridden to allow raising errors with just an error code.
    #
    # @param [Integer, String] code_or_message spotify error code, or string message.
    def initialize(code_or_message = nil)
      if code_or_message.is_a?(Integer) or code_or_message.is_a?(Symbol)
        code_or_message &&= self.class.explain(code_or_message)
      end

      super(code_or_message)
    end
  end
end
