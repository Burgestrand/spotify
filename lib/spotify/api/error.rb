module Spotify
  class API
    # @!group Error

    # @param [Symbol, Integer] error
    # @return [String] explanatory error message for an error code
    attach_function :error_message, [ :error ], UTF8String
  end
end
