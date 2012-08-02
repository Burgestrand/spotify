module Spotify
  class API
    # !@group ArtistBrowse
    attach_function :artistbrowse_create, [ Session, Artist, :artistbrowse_type, :artistbrowse_complete_cb, :userdata ], ArtistBrowse
    attach_function :artistbrowse_is_loaded, [ ArtistBrowse ], :bool
    attach_function :artistbrowse_error, [ ArtistBrowse ], :error
    attach_function :artistbrowse_artist, [ ArtistBrowse ], Artist
    attach_function :artistbrowse_num_portraits, [ ArtistBrowse ], :int
    attach_function :artistbrowse_portrait, [ ArtistBrowse, :int ], ImageID
    attach_function :artistbrowse_num_tracks, [ ArtistBrowse ], :int
    attach_function :artistbrowse_track, [ ArtistBrowse, :int ], Track
    attach_function :artistbrowse_num_albums, [ ArtistBrowse ], :int
    attach_function :artistbrowse_album, [ ArtistBrowse, :int ], Album
    attach_function :artistbrowse_num_similar_artists, [ ArtistBrowse ], :int
    attach_function :artistbrowse_similar_artist, [ ArtistBrowse, :int ], Artist
    attach_function :artistbrowse_biography, [ ArtistBrowse ], UTF8String
    attach_function :artistbrowse_backend_request_duration, [ ArtistBrowse ], :int
    attach_function :artistbrowse_num_tophit_tracks, [ ArtistBrowse ], :int
    attach_function :artistbrowse_tophit_track, [ ArtistBrowse, :int ], Track
    attach_function :artistbrowse_add_ref, [ ArtistBrowse ], :error
    attach_function :artistbrowse_release, [ ArtistBrowse ], :error
  end
end
