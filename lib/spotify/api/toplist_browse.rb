module Spotify
  class API
    # @!group ToplistBrowse

    # Initiate a request for browsing a toplist.
    #
    # @example
    #   callback = proc { |toplist_browse| puts "Toplist query finished!" }
    #   toplist_browse = Spotify.toplistbrowse_create(session, :tracks, :everywhere, nil, callback, nil)
    #
    # @example for sweden
    #   callback = proc { |toplist_browse| puts "Toplist query finished!" }
    #   toplist_browse = Spotify.toplistbrowse_create(session, :tracks, Spotify::CountryCode.to_native("SE", nil), nil, callback, nil)
    #
    # @note it is *very* important that the callback is not garbage collected before it is called!
    # @param [Session] session
    # @param [Symbol] type one of :artists, :albums, :tracks
    # @param [Symbol] region :everywhere, :user, or a CountryCode
    # @param [String, nil] username if region is :user this is the user to get toplists for, use nil for currently logged in user
    # @param [Proc<ToplistBrowse, FFI::Pointer>] callback
    # @param [FFI::Pointer] userdata
    # @method toplistbrowse_create(session, type, region, username, callback, userdata)
    attach_function :toplistbrowse_create, [ Session, :toplisttype, :toplistregion, UTF8String, :toplistbrowse_complete_cb, :userdata ], ToplistBrowse

    # @param [ToplistBrowse] toplist_browse
    # @return [Boolean] true if toplist request has finished loading
    # @method toplistbrowse_is_loaded(toplist_browse)
    attach_function :toplistbrowse_is_loaded, [ ToplistBrowse ], :bool

    # @param [ToplistBrowse] toplist_browse
    # @return [Symbol] error code
    # @method toplistbrowse_error(toplist_browse)
    attach_function :toplistbrowse_error, [ ToplistBrowse ], APIError

    # @see #toplistbrowse_is_loaded
    # @note if the toplist is not loaded, the function always return 0.
    # @param [ToplistBrowse] toplist_browse
    # @return [Integer] number of artists in the toplist result
    # @method toplistbrowse_num_artists(toplist_browse)
    attach_function :toplistbrowse_num_artists, [ ToplistBrowse ], :int

    # @see #toplistbrowse_num_artists
    # @note if index is out of range, the function always return nil.
    # @param [ToplistBrowse] toplist_browse
    # @param [Integer] index number between 0...{#toplistbrowse_num_artists}
    # @return [Artist, nil] artist at index
    # @method toplistbrowse_artist(toplist_browse, :int)
    attach_function :toplistbrowse_artist, [ ToplistBrowse, :int ], Artist

    # @see #toplistbrowse_is_loaded
    # @note if the toplist is not loaded, the function always return 0.
    # @param [ToplistBrowse] toplist_browse
    # @return [Integer] number of albums in the toplist result
    # @method toplistbrowse_num_albums(toplist_browse)
    attach_function :toplistbrowse_num_albums, [ ToplistBrowse ], :int

    # @see #toplistbrowse_num_albums
    # @note if index is out of range, the function always return nil.
    # @param [ToplistBrowse] toplist_browse
    # @param [Integer] index number between 0...{#toplistbrowse_num_albums}
    # @return [Album, nil] album at index
    # @method toplistbrowse_album(toplist_browse, index)
    attach_function :toplistbrowse_album, [ ToplistBrowse, :int ], Album

    # @see #toplistbrowse_is_loaded
    # @note if the toplist is not loaded, the function always return 0.
    # @param [ToplistBrowse] toplist_browse
    # @return [Integer] number of tracks in the toplist result
    # @method toplistbrowse_num_tracks(toplist_browse)
    attach_function :toplistbrowse_num_tracks, [ ToplistBrowse ], :int

    # @see #toplistbrowse_num_tracks
    # @note if index is out of range, the function always return nil.
    # @param [ToplistBrowse] toplist_browse
    # @param [Integer] index number between 0...{#toplistbrowse_num_tracks}
    # @return [Track, nil] track at index
    # @method toplistbrowse_track(toplist_browse, index)
    attach_function :toplistbrowse_track, [ ToplistBrowse, :int ], Track

    # @param [ToplistBrowse] toplist_browse
    # @return [Integer] the time in ms that was spent waiting for Spotify backend to serve request, or -1 if served from cache
    # @method toplistbrowse_backend_request_duration(toplist_browse)
    attach_function :toplistbrowse_backend_request_duration, [ ToplistBrowse ], :int

    attach_function :toplistbrowse_add_ref, [ ToplistBrowse ], APIError
    attach_function :toplistbrowse_release, [ ToplistBrowse ], APIError
  end
end
