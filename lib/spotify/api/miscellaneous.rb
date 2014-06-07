module Spotify
  class API
    # @!group Miscellaneous

    # @method build_id
    # @see Spotify::API_BUILD
    # @return [String] libspotify build ID
    attach_function :build_id, [], UTF8String

    # @!endgroup
  end
end
