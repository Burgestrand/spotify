module Spotify
  class API
    # @!group ToplistBrowse
    attach_function :toplistbrowse_create, [ Session, :toplisttype, :toplistregion, UTF8String, :toplistbrowse_complete_cb, :userdata ], ToplistBrowse
    attach_function :toplistbrowse_is_loaded, [ ToplistBrowse ], :bool
    attach_function :toplistbrowse_error, [ ToplistBrowse ], :error
    attach_function :toplistbrowse_num_artists, [ ToplistBrowse ], :int
    attach_function :toplistbrowse_artist, [ ToplistBrowse, :int ], Artist
    attach_function :toplistbrowse_num_albums, [ ToplistBrowse ], :int
    attach_function :toplistbrowse_album, [ ToplistBrowse, :int ], Album
    attach_function :toplistbrowse_num_tracks, [ ToplistBrowse ], :int
    attach_function :toplistbrowse_track, [ ToplistBrowse, :int ], Track
    attach_function :toplistbrowse_backend_request_duration, [ ToplistBrowse ], :int
    attach_function :toplistbrowse_add_ref, [ ToplistBrowse ], :error
    attach_function :toplistbrowse_release, [ ToplistBrowse ], :error
  end
end
