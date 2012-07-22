module Spotify
  attach_function :playlistcontainer_add_callbacks, [ PlaylistContainer, PlaylistContainerCallbacks, :userdata ], :error
  attach_function :playlistcontainer_remove_callbacks, [ PlaylistContainer, PlaylistContainerCallbacks, :userdata ], :error
  attach_function :playlistcontainer_num_playlists, [ PlaylistContainer ], :int
  attach_function :playlistcontainer_playlist, [ PlaylistContainer, :int ], Playlist
  attach_function :playlistcontainer_playlist_type, [ PlaylistContainer, :int ], :playlist_type
  attach_function :playlistcontainer_playlist_folder_name, [ PlaylistContainer, :int, :buffer_out, :int ], :error
  attach_function :playlistcontainer_playlist_folder_id, [ PlaylistContainer, :int ], :uint64
  attach_function :playlistcontainer_add_new_playlist, [ PlaylistContainer, UTF8String ], Playlist
  attach_function :playlistcontainer_add_playlist, [ PlaylistContainer, Link ], Playlist
  attach_function :playlistcontainer_remove_playlist, [ PlaylistContainer, :int ], :error
  attach_function :playlistcontainer_move_playlist, [ PlaylistContainer, :int, :int, :bool ], :error
  attach_function :playlistcontainer_add_folder, [ PlaylistContainer, :int, UTF8String ], :error
  attach_function :playlistcontainer_owner, [ PlaylistContainer ], User
  attach_function :playlistcontainer_is_loaded, [ PlaylistContainer ], :bool
  attach_function :playlistcontainer_get_unseen_tracks, [ PlaylistContainer, Playlist, :array, :int ], :int
  attach_function :playlistcontainer_clear_unseen_tracks, [ PlaylistContainer, Playlist ], :int
  attach_function :playlistcontainer_add_ref, [ PlaylistContainer ], :error
  attach_function :playlistcontainer_release, [ PlaylistContainer ], :error
end
