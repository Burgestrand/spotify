class SpotifyAPI
  # @!group Session
  attach_function :session_create, [ SessionConfig, :buffer_out ], :error
  attach_function :session_release, [ Session ], :error
  attach_function :session_process_events, [ Session, :buffer_out ], :error
  attach_function :session_login, [ Session, UTF8String, :string, :bool, :string ], :error
  attach_function :session_relogin, [ Session ], :error
  attach_function :session_forget_me, [ Session ], :error
  attach_function :session_remembered_user, [ Session, :buffer_out, :size_t ], :int
  attach_function :session_user, [ Session ], User
  attach_function :session_logout, [ Session ], :error
  attach_function :session_connectionstate, [ Session ], :connectionstate
  attach_function :session_userdata, [ Session ], :userdata
  attach_function :session_set_cache_size, [ Session, :size_t ], :error
  attach_function :session_player_load, [ Session, Track ], :error
  attach_function :session_player_seek, [ Session, :int ], :error
  attach_function :session_player_play, [ Session, :bool ], :error
  attach_function :session_player_unload, [ Session ], :error
  attach_function :session_player_prefetch, [ Session, Track ], :error
  attach_function :session_playlistcontainer, [ Session ], PlaylistContainer
  attach_function :session_inbox_create, [ Session ], Playlist
  attach_function :session_starred_create, [ Session ], Playlist
  attach_function :session_starred_for_user_create, [ Session, UTF8String ], Playlist
  attach_function :session_publishedcontainer_for_user_create, [ Session, UTF8String ], PlaylistContainer
  attach_function :session_preferred_bitrate, [ Session, :bitrate ], :error
  attach_function :session_set_connection_type, [ Session, :connection_type ], :error
  attach_function :session_set_connection_rules, [ Session, :connection_rules ], :error
  attach_function :offline_tracks_to_sync, [ Session ], :int
  attach_function :offline_num_playlists, [ Session ], :int
  attach_function :offline_sync_get_status, [ Session, OfflineSyncStatus ], :bool
  attach_function :offline_time_left, [ Session ], :int
  attach_function :session_user_country, [ Session ], :int
  attach_function :session_preferred_offline_bitrate, [ Session, :bitrate, :bool ], :error
  attach_function :session_set_volume_normalization, [ Session, :bool ], :error
  attach_function :session_get_volume_normalization, [ Session ], :bool
  attach_function :session_flush_caches, [ Session ], :error
  attach_function :session_user_name, [ Session ], :string
  attach_function :session_set_private_session, [ Session, :bool ], :error
  attach_function :session_is_private_session, [ Session ], :bool
  attach_function :session_set_scrobbling, [ Session, :social_provider, :scrobbling_state ], :error
  attach_function :session_is_scrobbling, [ Session, :social_provider, :buffer_out ], :error
  attach_function :session_is_scrobbling_possible, [ Session, :social_provider, :buffer_out ], :error
  attach_function :session_set_social_credentials, [ Session, :social_provider, UTF8String, :string ], :error
end
