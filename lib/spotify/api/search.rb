module Spotify
  class API
    # @!group Search

    # Fire off a search query for tracks, albums, artists, and playlists.
    #
    # @example
    #   callback = proc { |search| puts "Search results are available!" }
    #   search = Spotify.search_create(session, "Zanarkand", 0, 10, 0, 10, 0, 10, 0, 10, :standard, callback, nil)
    #
    # @note it is *very* important that the callback is not garbage collected before it is called!
    # @param [Session] session
    # @param [String] query
    # @param [Integer] track_offset
    # @param [Integer] track_count
    # @param [Integer] album_offset
    # @param [Integer] album_count
    # @param [Integer] artist_offset
    # @param [Integer] artist_count
    # @param [Integer] playlist_offset
    # @param [Integer] playlist_count
    # @param [Integer] search_type one of :standard, or :suggest
    # @param [Proc<Search, FFI::Pointer>] callback
    # @param [FFI::Pointer] userdata
    # @return [Search] a search
    # @method search_create(session, query, track_offset, track_count, album_offset, album_count, artist_offset, artist_count, playlist_offset, playlist_count, search_type, callback, userdata)
    attach_function :search_create, [ Session, UTF8String, :int, :int, :int, :int, :int, :int, :int, :int, :search_type, :search_complete_cb, :userdata ], Search

    # @param [Search] search
    # @return [Boolean] true if the search has completed
    # @method search_is_loaded(search)
    attach_function :search_is_loaded, [ Search ], :bool

    # @param [Search] search
    # @return [Symbol] error code
    # @method search_error(search)
    attach_function :search_error, [ Search ], APIError

    # @param [Search] search
    # @return [String] search query
    # @method search_query(search)
    attach_function :search_query, [ Search ], UTF8String

    # @see #search_is_loaded
    # @note if the search is not loaded, the function always return an empty string.
    # @param [Search] search
    # @return [String] spotify's guess at what the query might have meant instead
    # @method search_did_you_mean(search)
    attach_function :search_did_you_mean, [ Search ], UTF8String

    # @see #search_is_loaded
    # @see #search_total_tracks
    # @note if {#search_total_tracks} is larger than this number, you may retrieve additional
    #       results if you make the same search query again, but with a higher track_offset
    # @note if the search is not loaded, the function always return 0.
    # @param [Search] search
    # @return [Integer] number of tracks in the search result
    # @method search_num_tracks(search)
    attach_function :search_num_tracks, [ Search ], :int

    # @see #search_num_tracks
    # @note if index is out of range, the function always return nil.
    # @param [Search] search
    # @param [Integer] index number between 0...{#search_num_tracks}
    # @return [Track, nil] track at index
    # @method search_track(search, index)
    attach_function :search_track, [ Search, :int ], Track

    # @see #search_is_loaded
    # @see #search_total_albums
    # @note if {#search_total_albums} is larger than this number, you may retrieve additional
    #       results if you make the same search query again, but with a higher album_offset
    # @note if the search is not loaded, the function always return 0.
    # @param [Search] search
    # @return [Integer] number of albums in the search result
    # @method search_num_albums(search)
    attach_function :search_num_albums, [ Search ], :int

    # @see #search_num_albums
    # @note if index is out of range, the function always return nil.
    # @param [Search] search
    # @param [Integer] index number between 0...{#search_num_albums}
    # @return [Album, nil] album at index
    # @method search_album(search, index)
    attach_function :search_album, [ Search, :int ], Album

    # @see #search_is_loaded
    # @see #search_total_artists
    # @note if {#search_total_artists} is larger than this number, you may retrieve additional
    #       results if you make the same search query again, but with a higher artist_offset
    # @note if the search is not loaded, the function always return 0.
    # @param [Search] search
    # @return [Integer] number of artists in the search result
    # @method search_num_artists(search)
    attach_function :search_num_artists, [ Search ], :int

    # @see #search_num_artists
    # @note if index is out of range, the function always return nil.
    # @param [Search] search
    # @param [Integer] index number between 0...{#search_num_artists}
    # @return [Artist, nil] artist at index
    # @method search_artist(search, index)
    attach_function :search_artist, [ Search, :int ], Artist

    # @see #search_is_loaded
    # @see #search_total_playlists
    # @note if {#search_total_playlists} is larger than this number, you may retrieve additional
    #       results if you make the same search query again, but with a higher playlist_offset
    # @note if the search is not loaded, the function always return 0.
    # @param [Search] search
    # @return [Integer] number of playlists in the search result
    # @method search_num_playlists(search)
    attach_function :search_num_playlists, [ Search ], :int

    # @see #search_num_playlists
    # @note if index is out of range, the function always return nil.
    # @param [Search] search
    # @param [Integer] index number between 0...{#search_num_playlists}
    # @return [Playlist, nil] playlist at index
    # @method search_playlist(search, index)
    attach_function :search_playlist, [ Search, :int ], Playlist

    # @see #search_num_playlists
    # @note if index is out of range, the function always return nil.
    # @param [Search] search
    # @param [Integer] index number between 0...{#search_num_playlists}
    # @return [String, nil] name for playlist at index
    # @method search_playlist_name(search, index)
    attach_function :search_playlist_name, [ Search, :int ], UTF8String

    # @see #link_create_from_string
    # @see #search_num_playlists
    # @note if index is out of range, the function always return nil.
    # @param [Search] search
    # @param [Integer] index number between 0...{#search_num_playlists}
    # @return [String, nil] spotify uri for playlist at index
    # @method search_playlist_uri(search, index)
    attach_function :search_playlist_uri, [ Search, :int ], UTF8String

    # @see #image_create_from_link
    # @see #search_num_playlists
    # @note if index is out of range, the function always return nil.
    # @param [Search] search
    # @param [Integer] index number between 0...{#search_num_playlists}
    # @return [String, nil] image uri for playlist at index
    # @method search_playlist_image_uri(search, index)
    attach_function :search_playlist_image_uri, [ Search, :int ], UTF8String

    # @see #search_is_loaded
    # @note if the search is not loaded, the function always return 0.
    # @param [Search] search
    # @return [Integer] number of total tracks in the search result
    # @method search_total_tracks(search)
    attach_function :search_total_tracks, [ Search ], :int

    # @see #search_is_loaded
    # @note if the search is not loaded, the function always return 0.
    # @param [Search] search
    # @return [Integer] number of total albums in the search result
    # @method search_total_albums(search)
    attach_function :search_total_albums, [ Search ], :int

    # @see #search_is_loaded
    # @note if the search is not loaded, the function always return 0.
    # @param [Search] search
    # @return [Integer] number of total artists in the search result
    # @method search_total_artists(search)
    attach_function :search_total_artists, [ Search ], :int

    # @see #search_is_loaded
    # @note if the search is not loaded, the function always return 0.
    # @param [Search] search
    # @return [Integer] number of total playlists in the search result
    # @method search_total_playlists(search)
    attach_function :search_total_playlists, [ Search ], :int

    attach_function :search_add_ref, [ Search ], APIError
    attach_function :search_release, [ Search ], APIError
  end
end
