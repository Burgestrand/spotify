module Spotify
  class API
    # @!group Playlist
    attach_function :playlist_is_loaded, [ Playlist ], :bool
    attach_function :playlist_add_callbacks, [ Playlist, PlaylistCallbacks.by_ref, :userdata ], :error
    attach_function :playlist_remove_callbacks, [ Playlist, PlaylistCallbacks.by_ref, :userdata ], :error
    attach_function :playlist_num_tracks, [ Playlist ], :int
    attach_function :playlist_track, [ Playlist, :int ], Track
    attach_function :playlist_track_create_time, [ Playlist, :int ], :int
    attach_function :playlist_track_creator, [ Playlist, :int ], User
    attach_function :playlist_track_seen, [ Playlist, :int ], :bool
    attach_function :playlist_track_set_seen, [ Playlist, :int, :bool ], :error
    attach_function :playlist_track_message, [ Playlist, :int ], UTF8String
    attach_function :playlist_name, [ Playlist ], UTF8String
    attach_function :playlist_rename, [ Playlist, UTF8String ], :error
    attach_function :playlist_owner, [ Playlist ], User
    attach_function :playlist_is_collaborative, [ Playlist ], :bool
    attach_function :playlist_set_collaborative, [ Playlist, :bool ], :error
    attach_function :playlist_set_autolink_tracks, [ Playlist, :bool ], :error
    attach_function :playlist_get_description, [ Playlist ], UTF8String
    attach_function :playlist_get_image, [ Playlist, :buffer_out ], :bool
    attach_function :playlist_has_pending_changes, [ Playlist ], :bool
    attach_function :playlist_add_tracks, [ Playlist, :array, :int, :int, Session ], :error
    attach_function :playlist_remove_tracks, [ Playlist, :array, :int ], :error
    attach_function :playlist_reorder_tracks, [ Playlist, :array, :int, :int ], :error
    attach_function :playlist_num_subscribers, [ Playlist ], :uint
    attach_function :playlist_subscribers, [ Playlist ], Subscribers.auto_ptr
    attach_function :playlist_subscribers_free, [ Subscribers.by_ref ], :error
    attach_function :playlist_update_subscribers, [ Session, Playlist ], :error
    attach_function :playlist_is_in_ram, [ Session, Playlist ], :bool
    attach_function :playlist_set_in_ram, [ Session, Playlist, :bool ], :error
    attach_function :playlist_create, [ Session, Link ], Playlist
    attach_function :playlist_get_offline_status, [ Session, Playlist ], :playlist_offline_status
    attach_function :playlist_get_offline_download_completed, [ Session, Playlist ], :int
    attach_function :playlist_set_offline_mode, [ Session, Playlist, :bool ], :error
    attach_function :playlist_add_ref, [ Playlist ], :error
    attach_function :playlist_release, [ Playlist ], :error
  end
end
