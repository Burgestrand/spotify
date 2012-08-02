module Spotify
  class API
    # !@group AlbumBrowse
    attach_function :albumbrowse_create, [ Session, Album, :albumbrowse_complete_cb, :userdata ], AlbumBrowse
    attach_function :albumbrowse_is_loaded, [ AlbumBrowse ], :bool
    attach_function :albumbrowse_error, [ AlbumBrowse ], :error
    attach_function :albumbrowse_album, [ AlbumBrowse ], Album
    attach_function :albumbrowse_artist, [ AlbumBrowse ], Artist
    attach_function :albumbrowse_num_copyrights, [ AlbumBrowse ], :int
    attach_function :albumbrowse_copyright, [ AlbumBrowse, :int ], UTF8String
    attach_function :albumbrowse_num_tracks, [ AlbumBrowse ], :int
    attach_function :albumbrowse_track, [ AlbumBrowse, :int ], Track
    attach_function :albumbrowse_review, [ AlbumBrowse ], UTF8String
    attach_function :albumbrowse_backend_request_duration, [ AlbumBrowse ], :int
    attach_function :albumbrowse_add_ref, [ AlbumBrowse ], :error
    attach_function :albumbrowse_release, [ AlbumBrowse ], :error
  end
end
