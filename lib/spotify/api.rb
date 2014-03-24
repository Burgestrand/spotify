module Spotify
  class API
    # Overloaded to ensure all methods are defined as blocking,
    # and they return a managed pointer with the correct refcount.
    #
    # @param [#to_s] name function name sans `sp_` prefix.
    # @param [Array] args
    # @param [Object] returns
    def self.attach_function(c_name = nil, name, args, returns)
      if returns.respond_to?(:retaining_class) && name !~ /create/
        returns = returns.retaining_class
      end

      options  = { :blocking => true }
      c_name ||= "sp_#{name}"
      super(name, c_name, args, returns, options)
    end

    # Now, make sure we have the right libspotify version.

    # @!group Miscellaneous

    # @see Spotify::API_BUILD
    # @return [String] libspotify build ID
    attach_function :build_id, [], UTF8String

    # @!endgroup
  end

  # @return [String] libspotify build ID.
  API_BUILD = Spotify.build_id
end

require 'spotify/api/album'
require 'spotify/api/album_browse'
require 'spotify/api/artist'
require 'spotify/api/artist_browse'
require 'spotify/api/error'
require 'spotify/api/image'
require 'spotify/api/inbox'
require 'spotify/api/link'
require 'spotify/api/playlist'
require 'spotify/api/playlist_container'
require 'spotify/api/search'
require 'spotify/api/session'
require 'spotify/api/toplist_browse'
require 'spotify/api/track'
require 'spotify/api/user'
