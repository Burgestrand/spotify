module Spotify
  class API
    # @!group AlbumBrowse

    # @example
    #   # this is called some time later, as a result of calling {#session_process_events}
    #   browse_callback = proc do |album_browse|
    #     puts "Album browse has completed!"
    #   end
    #   album_browse = Spotify.albumbrowse_create(session, album, browse_callback, nil)
    #
    # @note make *very* sure the callback proc is not garbage collected before it is called!
    # @param [Session] session
    # @param [Album] album
    # @param [Proc<AlbumBrowse, FFI::Pointer>] callback
    # @param [FFI::Pointer] userdata
    # @return [AlbumBrowse] a request for browsing an album
    # @method albumbrowse_create(session, album, albumbrowse_complete_callback, userdata)
    attach_function :albumbrowse_create, [ Session, Album, :albumbrowse_complete_cb, :userdata ], AlbumBrowse

    # @param [AlbumBrowse] album_browse
    # @return [Boolean] true if the album browse request has completed
    # @method albumbrowse_is_loaded(album_browse)
    attach_function :albumbrowse_is_loaded, [ AlbumBrowse ], :bool

    # @param [AlbumBrowse] album_browse
    # @return [Symbol] album browsing error code
    # @method albumbrowse_error(album_browse)
    attach_function :albumbrowse_error, [ AlbumBrowse ], :error

    # @see #albumbrowse_is_loaded
    # @note the album browse request must have completed, or this function always return nil.
    # @param [AlbumBrowse] album_browse
    # @return [Album, nil] the album being browsed
    # @method albumbrowse_album(album_browse)
    attach_function :albumbrowse_album, [ AlbumBrowse ], Album

    # @see #albumbrowse_is_loaded
    # @note the album browse request must have completed, or this function always return nil.
    # @param [AlbumBrowse] album_browse
    # @return [Artist, nil] the authoring artist of the album being browsed
    # @method albumbrowse_artist(album_browse)
    attach_function :albumbrowse_artist, [ AlbumBrowse ], Artist

    # @see #albumbrowse_is_loaded
    # @see #albumbrowse_copyright
    # @note the album browse request must have completed, or this function always return 0.
    # @param [AlbumBrowse] album_browse
    # @return [Integer] number of copyright strings on the album being browsed
    # @method albumbrowse_num_copyrights(album_browse)
    attach_function :albumbrowse_num_copyrights, [ AlbumBrowse ], :int

    # @see #albumbrowse_is_loaded
    # @see #albumbrowse_num_copyrights
    # @note if index is out of range, returns nil.
    # @param [AlbumBrowse] album_browse
    # @param [Integer] index number within 0...{#albumbrowse_num_copyrights}
    # @return [String, nil] the copyright string at index
    # @method albumbrowse_copyright(album_browse, index)
    attach_function :albumbrowse_copyright, [ AlbumBrowse, :int ], UTF8String

    # @see #albumbrowse_is_loaded
    # @see #albumbrowse_track
    # @note the album browse request must have completed, or this function always return 0.
    # @param [AlbumBrowse] album_browse
    # @return [Integer] number of tracks on the album being browsed
    # @method albumbrowse_num_tracks(album_browse)
    attach_function :albumbrowse_num_tracks, [ AlbumBrowse ], :int

    # @see #albumbrowse_is_loaded
    # @see #albumbrowse_num_tracks
    # @note if index is out of range, returns nil.
    # @param [AlbumBrowse] album_browse
    # @param [Integer] index number within 0...{#albumbrowse_num_tracks}
    # @return [Track, nil] the track at index
    # @method albumbrowse_track(album_browse, index)
    attach_function :albumbrowse_track, [ AlbumBrowse, :int ], Track

    # @see #albumbrowse_is_loaded
    # @note the album browse request must have completed, or this function always return an empty string.
    # @param [AlbumBrowse] album_browse
    # @return [String] the review for the album being browsed
    # @method albumbrowse_review(album_browse)
    attach_function :albumbrowse_review, [ AlbumBrowse ], UTF8String

    # @see #albumbrowse_is_loaded
    # @note the album browse request must have completed, or this function will return an undefined value.
    # @param [AlbumBrowse] album_browse
    # @return [Integer] the time (in ms) that was spent waiting for the Spotify backend to serve the request, -1 if served from local cache
    # @method albumbrowse_backend_request_duration(album_browse)
    attach_function :albumbrowse_backend_request_duration, [ AlbumBrowse ], :int

    attach_function :albumbrowse_add_ref, [ AlbumBrowse ], :error
    attach_function :albumbrowse_release, [ AlbumBrowse ], :error
  end
end
