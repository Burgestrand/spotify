class SpotifyAPI
  # @!group Track
  attach_function :track_is_loaded, [ Track ], :bool
  attach_function :track_error, [ Track ], :error
  attach_function :track_get_availability, [ Session, Track ], :track_availability
  attach_function :track_is_local, [ Session, Track ], :bool
  attach_function :track_is_autolinked, [ Session, Track ], :bool
  attach_function :track_is_starred, [ Session, Track ], :bool
  attach_function :track_set_starred, [ Session, :array, :int, :bool ], :error
  attach_function :track_num_artists, [ Track ], :int
  attach_function :track_artist, [ Track, :int ], Artist
  attach_function :track_album, [ Track ], Album
  attach_function :track_name, [ Track ], UTF8String
  attach_function :track_duration, [ Track ], :int
  attach_function :track_popularity, [ Track ], :int
  attach_function :track_disc, [ Track ], :int
  attach_function :track_index, [ Track ], :int
  attach_function :track_is_placeholder, [ Track ], :bool
  attach_function :track_get_playable,  [ Session, Track ], Track
  attach_function :track_offline_get_status, [ Track ], :track_offline_status
  attach_function :localtrack_create, [ UTF8String, UTF8String, UTF8String, :int ], Track
  attach_function :track_add_ref, [ Track ], :error
  attach_function :track_release, [ Track ], :error
end
