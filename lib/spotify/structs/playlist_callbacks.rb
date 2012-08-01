class SpotifyAPI
  # SpotifyAPI::Struct for Playlist callbacks.
  #
  # @attr [callback(Playlist, :array, :int, :int, :userdata):void] tracks_added
  # @attr [callback(Playlist, :array, :int, :userdata):void] tracks_removed
  # @attr [callback(Playlist, :array, :int, :int, :userdata):void] tracks_moved
  # @attr [callback(Playlist, :userdata):void] playlist_renamed
  # @attr [callback(Playlist, :userdata):void] playlist_state_changed
  # @attr [callback(Playlist, :bool, :userdata):void] playlist_update_in_progress
  # @attr [callback(Playlist, :userdata):void] playlist_metadata_updated
  # @attr [callback(Playlist, :int, User, :int, :userdata):void] track_created_changed
  # @attr [callback(Playlist, :int, :bool, :userdata):void] track_seen_changed
  # @attr [callback(Playlist, UTF8String, :userdata):void] description_changed
  # @attr [callback(Playlist, ImageID, :userdata):void] image_changed
  # @attr [callback(Playlist, :int, UTF8String, :userdata):void] track_message_changed
  # @attr [callback(Playlist, :userdata):void] subscribers_changed
  class PlaylistCallbacks < SpotifyAPI::Struct
    layout :tracks_added => callback([ Playlist.retaining_class, :array, :int, :int, :userdata ], :void),
           :tracks_removed => callback([ Playlist.retaining_class, :array, :int, :userdata ], :void),
           :tracks_moved => callback([ Playlist.retaining_class, :array, :int, :int, :userdata ], :void),
           :playlist_renamed => callback([ Playlist.retaining_class, :userdata ], :void),
           :playlist_state_changed => callback([ Playlist.retaining_class, :userdata ], :void),
           :playlist_update_in_progress => callback([ Playlist.retaining_class, :bool, :userdata ], :void),
           :playlist_metadata_updated => callback([ Playlist.retaining_class, :userdata ], :void),
           :track_created_changed => callback([ Playlist.retaining_class, :int, User.retaining_class, :int, :userdata ], :void),
           :track_seen_changed => callback([ Playlist.retaining_class, :int, :bool, :userdata ], :void),
           :description_changed => callback([ Playlist.retaining_class, UTF8String, :userdata ], :void),
           :image_changed => callback([ Playlist.retaining_class, ImageID, :userdata ], :void),
           :track_message_changed => callback([ Playlist.retaining_class, :int, UTF8String, :userdata ], :void),
           :subscribers_changed => callback([ Playlist.retaining_class, :userdata ], :void)
  end
end
