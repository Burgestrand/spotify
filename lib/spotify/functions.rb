class SpotifyAPI
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
  API_BUILD = build_id

  unless API_BUILD.include?(SpotifyAPI::API_VERSION)
    raise LoadError, "libspotify v#{build_id} is incompatible with ruby spotify v#{VERSION}(#{API_VERSION})"
  end
end

require 'spotify/functions/album'
require 'spotify/functions/album_browse'
require 'spotify/functions/artist'
require 'spotify/functions/artist_browse'
require 'spotify/functions/error'
require 'spotify/functions/image'
require 'spotify/functions/inbox'
require 'spotify/functions/link'
require 'spotify/functions/playlist'
require 'spotify/functions/playlist_container'
require 'spotify/functions/search'
require 'spotify/functions/session'
require 'spotify/functions/toplist_browse'
require 'spotify/functions/track'
require 'spotify/functions/user'

require 'spotify/functions/error_wrapped'
