module Spotify
  attach_function :search_create, [ Session, UTF8String, :int, :int, :int, :int, :int, :int, :int, :int, :search_type, :search_complete_cb, :userdata ], Search
  attach_function :search_is_loaded, [ Search ], :bool
  attach_function :search_error, [ Search ], :error
  attach_function :search_query, [ Search ], UTF8String
  attach_function :search_did_you_mean, [ Search ], UTF8String
  attach_function :search_num_tracks, [ Search ], :int
  attach_function :search_track, [ Search, :int ], Track
  attach_function :search_num_albums, [ Search ], :int
  attach_function :search_album, [ Search, :int ], Album
  attach_function :search_num_artists, [ Search ], :int
  attach_function :search_artist, [ Search, :int ], Artist
  attach_function :search_num_playlists, [ Search ], :int
  attach_function :search_playlist, [ Search, :int ], Playlist
  attach_function :search_playlist_name, [ Search, :int ], UTF8String
  attach_function :search_playlist_uri, [ Search, :int ], UTF8String
  attach_function :search_playlist_image_uri, [ Search, :int ], UTF8String
  attach_function :search_total_tracks, [ Search ], :int
  attach_function :search_total_albums, [ Search ], :int
  attach_function :search_total_artists, [ Search ], :int
  attach_function :search_total_playlists, [ Search ], :int
  attach_function :search_add_ref, [ Search ], :error
  attach_function :search_release, [ Search ], :error
end
