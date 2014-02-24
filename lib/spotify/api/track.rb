module Spotify
  class API
    # @!group Track

    # @param [Track] track
    # @return [Boolean] true if track has finished loading
    attach_function :track_is_loaded, [ Track ], :bool

    # @param [Track] track
    # @return [Symbol] error code
    attach_function :track_error, [ Track ], :error

    # @see #track_is_loaded
    # @note if the track is not loaded, the function always return :unavailable.
    # @param [Session] session
    # @param [Track] track
    # @return [Symbol] track availability, one of :unavailable, :available, :not_streamable, :banned_by_artist
    attach_function :track_get_availability, [ Session, Track ], :track_availability

    # @note if the track is not loaded, the function always return false.
    # @param [Session] session
    # @param [Track] track
    # @return [Boolean] true if the track is a local track
    attach_function :track_is_local, [ Session, Track ], :bool

    # @note if the track is not loaded, the function always return false.
    # @param [Session] session
    # @param [Track] track
    # @return [Boolean] true if the track is automatically linked to another playable version of the track
    attach_function :track_is_autolinked, [ Session, Track ], :bool

    # @note if the track is not loaded, the function always return false.
    # @param [Session] session
    # @param [Track] track
    # @return [Boolean] true if the track is starred by the current user
    attach_function :track_is_starred, [ Session, Track ], :bool

    # Star or unstar a list of tracks.
    #
    # @example
    #   tracks = [track_a, track_b]
    #   starred = true
    #   error = FFI::MemoryPointer.new(Spotify::Track, tracks.length) do |tracks_array|
    #     tracks_array.write_array_of_pointer(tracks)
    #     break Spotify.track_set_starred(session, tracks_array, tracks.length, starred)
    #   end # => :ok
    #
    # @param [Session] session
    # @param [FFI::Pointer<Track>] tracks_pointer
    # @param [Integer] tracks_pointer_count
    # @param [Boolean] starred true if tracks should be starred, false if unstarred
    # @return [Symbol] error code
    attach_function :track_set_starred, [ Session, :array, :int, :bool ], :error

    # @note if the track is not loaded, the function always return 0.
    # @param [Track] track
    # @return [Integer] number of artists performing the track
    attach_function :track_num_artists, [ Track ], :int

    # @see #track_num_artists
    # @note if index is out of range, the function always return nil.
    # @param [Track] track
    # @param [Integer] index number between 0...{#track_num_artists}
    # @return [Artist, nil] artist at index
    attach_function :track_artist, [ Track, :int ], Artist

    # @note if the track is not loaded, the function always return nil.
    # @param [Track] track
    # @return [Album, nil] album of the track
    attach_function :track_album, [ Track ], Album

    # @note if the track is not loaded, the function always return an empty string.
    # @param [Track] track
    # @return [String] track name
    attach_function :track_name, [ Track ], UTF8String

    # @note if the track is not loaded, the function always return 0.
    # @param [Track] track
    # @return [Integer] duration of the track in milliseconds
    attach_function :track_duration, [ Track ], :int

    # @note if the track is not loaded, the function always return 0.
    # @param [Track] track
    # @return [Integer] popularity of the track, 0..100
    attach_function :track_popularity, [ Track ], :int

    # @note The function only returns valid data for tracks appearing in an ArtistBrowse or AlbumBrowse result.
    # @note if the disc is not available, the function always return 0.
    # @param [Track] track
    # @return [Integer] disc number for the track, 1..(total number of discs on album)
    attach_function :track_disc, [ Track ], :int

    # @note The function only returns valid data for tracks appearing in an ArtistBrowse or AlbumBrowse result.
    # @note if the disc is not available, the function always return 0.
    # @param [Track] track
    # @return [Integer] position of track on it's disc, starts at 1
    attach_function :track_index, [ Track ], :int

    # Placeholder tracks are a way to store non-track items in a playlist.
    #
    # This is used when sending playlists to users, for example.
    #
    # @see #link_create_from_track
    # @note the track does not need to be loaded for this function to return a correct value.
    # @note use {#link_create_from_track} to get a link to the wrapped item.
    # @param [Track] track
    # @return [Boolean] true if track is a placeholder
    attach_function :track_is_placeholder, [ Track ], :bool

    # @note If the track has been autolinked, the returned track will not be the same track.
    # @param [Track] track
    # @return [Track] the actual track that will be played if track is scheduled for playback
    attach_function :track_get_playable,  [ Session, Track ], Track

    # @param [Track] track
    # @return [Symbol] offline status of track, one of :no, :waiting, :downloading, :done, :error, :done_expired, :limit_exceeded, :done_resync
    attach_function :track_offline_get_status, [ Track ], :track_offline_status

    # Create a local Track reference, whatever that means.
    #
    # @example
    #   track = Spotify.localtrack_create("Indianer", "The Best Of Indianer", "Armonia", 343_000)
    #   # track spotify URI is: spotify:local:Indianer:Armonia:The+Best+Of+Indianer:34
    #
    # @param [String] artist
    # @param [String] title
    # @param [String] album
    # @param [Integer] duration in milliseconds, or -1 if not available
    # @return [Track]
    attach_function :localtrack_create, [ UTF8String, UTF8String, UTF8String, :int ], Track

    attach_function :track_add_ref, [ Track ], :error
    attach_function :track_release, [ Track ], :error
  end
end
