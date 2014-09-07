module Spotify
  class API
    # @!group Error

    # @param [Error] error
    # @return [String] explanatory error message for an error code
    # @method error_message(error)
    attach_function :error_message, [ APIError ], UTF8String
  end
end
