module Spotify
  class API
    # @!macro [attach] attach_function
    #   @!method $1(…)
    #     @!scope class
    #     @example method signature (shows arguments)
    #       $*
    #     @return [${-1}]
    #
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
    attach_function :build_id, [], UTF8String
    API_BUILD = Spotify.build_id

    unless API_BUILD.include?(Spotify::API_VERSION)
      raise LoadError, "libspotify v#{build_id} is incompatible with ruby spotify v#{VERSION}(#{API_VERSION})"
    end
  end
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
