module Spotify
  class API
    # @!group ArtistBrowse

    # @example
    #   # this is called some time later, as a result of calling {#session_process_events}
    #   browse_callback = proc do |artist_browse|
    #     puts "Artist browse has completed!"
    #   end
    #   artist_browse = Spotify.artistbrowse_create(session, artist, :no_albums, browse_callback, nil)
    #
    # @note make *very* sure the callback proc is not garbage collected before it is called!
    # @param [Session] session
    # @param [Artist] artist
    # @param [Symbol] type one of :full, :no_tracks, :no_albums
    # @param [Proc<ArtistBrowse, FFI::Pointer>] callback
    # @param [FFI::Pointer] userdata
    # @return [ArtistBrowse] a request for browsing an artist
    attach_function :artistbrowse_create, [ Session, Artist, :artistbrowse_type, :artistbrowse_complete_cb, :userdata ], ArtistBrowse

    # @param [ArtistBrowse] artist_browse
    # @return [Boolean] true if the artist browse request has completed
    attach_function :artistbrowse_is_loaded, [ ArtistBrowse ], :bool

    # @param [ArtistBrowse] artist_browse
    # @return [Symbol] artist browsing error code
    attach_function :artistbrowse_error, [ ArtistBrowse ], :error

    # @see #artistbrowse_is_loaded
    # @note the artist browse request must have completed, or this function always return nil.
    # @param [ArtistBrowse] artist_browse
    # @return [Artist, nil] the artist being browsed
    attach_function :artistbrowse_artist, [ ArtistBrowse ], Artist

    # @see #artistbrowse_is_loaded
    # @see #artistbrowse_portrait
    # @note the artist browse request must have completed, or this function always return 0.
    # @param [ArtistBrowse] artist_browse
    # @return [Integer] number of artist portraits
    attach_function :artistbrowse_num_portraits, [ ArtistBrowse ], :int

    # @see #artistbrowse_is_loaded
    # @see #artistbrowse_num_portraits
    # @note if index is out of range, returns nil.
    # @param [ArtistBrowse] artist_browse
    # @param [Integer] index number within 0...{#artistbrowse_num_portraits}
    # @return [String, nil] image ID to pass to {#image_create}
    attach_function :artistbrowse_portrait, [ ArtistBrowse, :int ], ImageID

    # @see #artistbrowse_is_loaded
    # @see #artistbrowse_track
    # @note the artist browse request must have completed, or this function always return 0.
    # @param [ArtistBrowse] artist_browse
    # @return [Integer] number of artist tracks
    attach_function :artistbrowse_num_tracks, [ ArtistBrowse ], :int

    # @see #artistbrowse_is_loaded
    # @see #artistbrowse_num_tracks
    # @note if index is out of range, returns nil.
    # @param [ArtistBrowse] artist_browse
    # @param [Integer] index number within 0...{#artistbrowse_num_tracks}
    # @return [Track, nil] the track at index
    attach_function :artistbrowse_track, [ ArtistBrowse, :int ], Track

    # @see #artistbrowse_is_loaded
    # @see #artistbrowse_album
    # @note the artist browse request must have completed, or this function always return 0.
    # @param [ArtistBrowse] artist_browse
    # @return [Integer] number of artist albums
    attach_function :artistbrowse_num_albums, [ ArtistBrowse ], :int

    # @see #artistbrowse_is_loaded
    # @see #artistbrowse_num_albums
    # @note if index is out of range, returns nil.
    # @param [ArtistBrowse] artist_browse
    # @param [Integer] index number within 0...{#artistbrowse_num_albums}
    # @return [Track, nil] the album at index
    attach_function :artistbrowse_album, [ ArtistBrowse, :int ], Album

    # @see #artistbrowse_is_loaded
    # @see #artistbrowse_similar_artist
    # @note the artist browse request must have completed, or this function always return 0.
    # @param [ArtistBrowse] artist_browse
    # @return [Integer] number of similar artists
    attach_function :artistbrowse_num_similar_artists, [ ArtistBrowse ], :int

    # @see #artistbrowse_is_loaded
    # @see #artistbrowse_num_similar_artists
    # @note if index is out of range, returns nil.
    # @param [ArtistBrowse] artist_browse
    # @param [Integer] index number within 0...{#artistbrowse_num_similar_artists}
    # @return [Track, nil] a similar artist at index
    attach_function :artistbrowse_similar_artist, [ ArtistBrowse, :int ], Artist

    # @see #artistbrowse_is_loaded
    # @note the artist browse request must have completed, or this function always return an empty string.
    # @param [ArtistBrowse] artist_browse
    # @return [String] the review for the artist being browsed
    attach_function :artistbrowse_biography, [ ArtistBrowse ], UTF8String

    # @see #artistbrowse_is_loaded
    # @note the artist browse request must have completed, or this function will return an undefined value.
    # @param [ArtistBrowse] artist_browse
    # @return [Integer] the time (in ms) that was spent waiting for the Spotify backend to serve the request, -1 if served from local cache
    attach_function :artistbrowse_backend_request_duration, [ ArtistBrowse ], :int

    # @see #artistbrowse_is_loaded
    # @see #artistbrowse_tophit_track
    # @note the artist browse request must have completed, or this function always return 0.
    # @param [ArtistBrowse] artist_browse
    # @return [Integer] number of tophit tracks
    attach_function :artistbrowse_num_tophit_tracks, [ ArtistBrowse ], :int

    # @see #artistbrowse_is_loaded
    # @see #artistbrowse_num_tophit_tracks
    # @note if index is out of range, returns nil.
    # @param [ArtistBrowse] artist_browse
    # @param [Integer] index number within 0...{#artistbrowse_num_tophit_tracks}
    # @return [Track, nil] the tophit track at index
    attach_function :artistbrowse_tophit_track, [ ArtistBrowse, :int ], Track

    attach_function :artistbrowse_add_ref, [ ArtistBrowse ], :error
    attach_function :artistbrowse_release, [ ArtistBrowse ], :error
  end
end
