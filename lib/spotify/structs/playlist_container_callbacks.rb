class SpotifyAPI
  # SpotifyAPI::Struct for the PlaylistContainer.
  #
  # @attr [callback(PlaylistContainer, Playlist, :int, :userdata):void] playlist_added
  # @attr [callback(PlaylistContainer, Playlist, :int, :userdata):void] playlist_removed
  # @attr [callback(PlaylistContainer, Playlist, :int, :int, :userdata):void] playlist_moved
  # @attr [callback(PlaylistContainer, :userdata):void] container_loaded
  class PlaylistContainerCallbacks < SpotifyAPI::Struct
    layout :playlist_added, callback([ PlaylistContainer.retaining_class, Playlist.retaining_class, :int, :userdata ], :void),
           :playlist_removed, callback([ PlaylistContainer.retaining_class, Playlist.retaining_class, :int, :userdata ], :void),
           :playlist_moved, callback([ PlaylistContainer.retaining_class, Playlist.retaining_class, :int, :int, :userdata ], :void),
           :container_loaded, callback([ PlaylistContainer.retaining_class, :userdata ], :void)
  end
end
