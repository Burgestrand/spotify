module Spotify
  class API
    # @!group Playlist

    # @param [Playlist] playlist
    # @return [Boolean] true if playlist is loaded
    # @method playlist_is_loaded(playlist)
    attach_function :playlist_is_loaded, [ Playlist ], :bool

    # Attach callbacks to the playlist, used for getting change notifications.
    #
    # @example
    #   callbacks = Spotify::PlaylistCallbacks.new({
    #     tracks_added: proc do |playlist, tracks_pointer, count, position|
    #       puts "#{count} tracks added at #{position}."
    #     end,
    #     playlist_renamed: proc { |playlist| puts "Playlist renamed!" },
    #   })
    #   Spotify.playlist_add_callbacks(playlist, callbacks, nil) # => ok
    #
    # @note it is *very* important that the callbacks are not garbage collected before they are called!
    # @param [Playlist] playlist
    # @param [PlaylistCallbacks] playlist_callbacks
    # @param [FFI::Pointer] userdata
    # @return [Symbol] error code
    # @method playlist_add_callbacks(playlist, playlist_callbacks, userdata)
    attach_function :playlist_add_callbacks, [ Playlist, PlaylistCallbacks.by_ref, :userdata ], :error

    # Remove playlist callbacks previously added with {#playlist_add_callbacks}.
    #
    # @see #playlist_add_callbacks
    # @param [Playlist] playlist
    # @param [PlaylistCallbacks] playlist_callbacks
    # @param [FFI::Pointer] userdata
    # @return [Symbol] error code
    # @method playlist_remove_callbacks(playlist, playlist_callbacks, userdata)
    attach_function :playlist_remove_callbacks, [ Playlist, PlaylistCallbacks.by_ref, :userdata ], :error

    # @see #playlist_track
    # @note if playlist is not loaded, the function always return 0.
    # @param [Playlist] playlist
    # @return [Integer] number of tracks in the playlist
    # @method playlist_num_tracks(playlist)
    attach_function :playlist_num_tracks, [ Playlist ], :int

    # @see #playlist_num_tracks
    # @note if index is out of range, the function always return nil.
    # @param [Playlist] playlist
    # @param [Integer] index number between 0...{#playlist_num_tracks}
    # @return [Track, nil] track at index
    # @method playlist_track(playlist, index)
    attach_function :playlist_track, [ Playlist, :int ], Track

    # @see #playlist_num_tracks
    # @note if index is out of range, the function always return -1.
    # @param [Playlist] playlist
    # @param [Integer] index number between 0...{#playlist_num_tracks}
    # @return [Integer] time in seconds since unix epoch that track was added at index in the playlist
    # @method playlist_track_create_time(playlist, index)
    attach_function :playlist_track_create_time, [ Playlist, :int ], :int

    # @see #playlist_num_tracks
    # @note if index is out of range, the function always return nil.
    # @param [Playlist] playlist
    # @param [Integer] index number between 0...{#playlist_num_tracks}
    # @return [User, nil] user that added the track at index in the playlist
    # @method playlist_track_creator(playlist, index)
    attach_function :playlist_track_creator, [ Playlist, :int ], User

    # @see #playlist_num_tracks
    # @see #playlist_track_set_seen
    # @note if index is out of range, the function always return false.
    # @param [Playlist] playlist
    # @param [Integer] index number between 0...{#playlist_num_tracks}
    # @return [Boolean] true if playlist has been marked as seen with {#playlist_track_set_seen}.
    # @method playlist_track_seen(playlist, index)
    attach_function :playlist_track_seen, [ Playlist, :int ], :bool

    # Set `seen` flag on track. The flag can be retrieved by {#playlist_track_seen}.
    #
    # @see #playlist_num_tracks
    # @see #playlist_track_seen
    # @param [Playlist] playlist
    # @param [Integer] index number between 0...{#playlist_num_tracks}
    # @param [Boolean] seen
    # @return [Symbol] error code
    # @method playlist_track_set_seen(playlist, index, seen)
    attach_function :playlist_track_set_seen, [ Playlist, :int, :bool ], :error

    # @see #playlist_num_tracks
    # @note if index is out of range, the function always return nil.
    # @param [Playlist] playlist
    # @param [Integer] index number between 0...{#playlist_num_tracks}
    # @return [String] message attached to a playlist item
    # @method playlist_track_message(playlist, index)
    attach_function :playlist_track_message, [ Playlist, :int ], UTF8String

    # @see #playlist_is_loaded
    # @note if playlist is not loaded, the function always return an empty string.
    # @param [Playlist] playlist
    # @return [String] name of the playlist
    # @method playlist_name(playlist)
    attach_function :playlist_name, [ Playlist ], UTF8String

    # Rename the playlist.
    #
    # @see #playlist_is_loaded
    # @note if playlist is not loaded, the function always return :permission_denied.
    # @param [Playlist] playlist
    # @param [String] new_name new name of the playlist
    # @return [Symbol] error code
    # @method playlist_rename(playlist, new_name)
    attach_function :playlist_rename, [ Playlist, UTF8String ], :error

    # @param [Playlist] playlist
    # @return [User] owner of the playlist
    # @method playlist_owner(playlist)
    attach_function :playlist_owner, [ Playlist ], User

    # @see #playlist_is_loaded
    # @see #playlist_set_collaborative
    # @note if {#playlist_set_collaborative} was used, the final value will not be
    #       visible until after libspotify has negotiated with Spotify backend.
    # @note if playlist is not loaded, the function always return false.
    # @param [Playlist] playlist
    # @return [Boolean] true if the playlist is collaborative, i.e. editable by others.
    # @method playlist_is_collaborative(playlist)
    attach_function :playlist_is_collaborative, [ Playlist ], :bool

    # Set collaborative status on a playlist.
    #
    # @see #playlist_is_collaborative
    # @note the function always return :ok.
    # @param [Playlist] playlist
    # @param [Boolean] collaborative
    # @return [Symbol] error code
    # @method playlist_set_collaborative(playlist, collaborative)
    attach_function :playlist_set_collaborative, [ Playlist, :bool ], :error

    # Set autolinking state for a playlist.
    #
    # If a playlist is set to autolink, unplayable tracks will be made playable by
    # linking them to an equivalent playable track when possible.
    #
    # @note the function always return :ok.
    # @param [Playlist] playlist
    # @param [Boolean] autolink
    # @return [Symbol] error code
    # @method playlist_set_autolink_tracks(playlist, autolink)
    attach_function :playlist_set_autolink_tracks, [ Playlist, :bool ], :error

    # @see #playlist_is_loaded
    # @note if the playlist is not loaded, the function always return nil.
    # @param [Playlist] playlist
    # @return [String, nil] playlist description, if available
    # @method playlist_get_description(playlist)
    attach_function :playlist_get_description, [ Playlist ], UTF8String

    # Retrieve playlist image ID as a string.
    #
    # @example
    #   Spotify.playlist_get_image(playlist) # =>
    #
    # @see #playlist_is_loaded
    # @see #image_create
    # @note if the playlist is not loaded, the function always return nil.
    # @param [Playlist] playlist
    # @return [String, nil] image ID for playlist image, or nil if no image available.
    # @method playlist_get_image(playlist)
    attach_function :playlist_get_image, [ Playlist, :buffer_out ], :bool do |playlist|
      with_buffer(Spotify::ImageID) do |image_id_buffer|
        if sp_playlist_get_image(playlist, image_id_buffer)
          ImageID.from_native(image_id_buffer, nil)
        end
      end
    end

    # @see #playlist_is_loaded
    # @note if the playlist is not loaded, the function always return true.
    # @param [Playlist] playlist
    # @return [Boolean] true if the playlist has local changes that have not yet been acknowledged by Spotify backend
    # @method playlist_has_pending_changes(playlist)
    attach_function :playlist_has_pending_changes, [ Playlist ], :bool

    # Add tracks to the playlist.
    #
    # @example single track
    #   Spotify.playlist_add_tracks(playlist, track, offset, session) # => :ok
    #
    # @example array of tracks
    #   Spotify.playlist_add_tracks(playlist, tracks, offset, session) # => :ok
    #
    # @see #playlist_is_loaded
    # @note if the playlist is not loaded, the function always return an error.
    #
    # @param [Playlist] playlist
    # @param [Array<Track>, Track] tracks
    # @param [Integer] offset starting index to add tracks from
    # @param [Session] session
    # @return [Symbol] error code
    # @method playlist_add_tracks(playlist, tracks, offset, session)
    attach_function :playlist_add_tracks, [ Playlist, :array, :int, :int, Session ], :error do |playlist, tracks, offset, session|
      tracks = Array(tracks)

      with_buffer(Spotify::Track, size: tracks.length) do |tracks_buffer|
        tracks_buffer.write_array_of_pointer(tracks)
        sp_playlist_add_tracks(playlist, tracks_buffer, tracks.length, offset, session)
      end
    end

    # Remove tracks from the playlist at the given indices.
    #
    # @example single index
    #   Spotify.playlist_remove_tracks(playlist, 3) # => :ok
    #
    # @example array of indices
    #   Spotify.playlist_remove_tracks(playlist, [1, 3]) # => :ok
    #
    # @see #playlist_is_loaded
    # @note if the playlist is not loaded, the function always return an error.
    # @note any index in indices_pointer must exist at most once, i.e. [0,1,2] is valid, [0,0,1] is not.
    # @param [Playlist] playlist
    # @param [Array<Integer>, Integer] indices_pointer pointer to array of track indices
    # @return [Symbol] error code
    # @method playlist_remove_tracks(playlist, indices)
    attach_function :playlist_remove_tracks, [ Playlist, :array, :int ], :error do |playlist, indices|
      indices = Array(indices)

      with_buffer(:int, size: indices.length) do |indices_buffer|
        indices_buffer.write_array_of_int(indices)
        sp_playlist_remove_tracks(playlist, indices_buffer, indices.length)
      end
    end

    # Move tracks at the given indices to position index and forward.
    #
    # @example
    #   Spotify.playlist_reorder_tracks(playlist, [1, 7], 0) # => :ok
    #
    # @see #playlist_is_loaded
    # @note if the playlist is not loaded, the function always return an error.
    # @note any index in indices_pointer must exist at most once, i.e. [0,1,2] is valid, [0,0,1] is not.
    # @param [Playlist] playlist
    # @param [Array<Integer>] indices_pointer pointer to array of track indices
    # @param [Integer] index starting position of tracks to be placed at, number between 0..{#playlist_num_tracks}
    # @return [Symbol] error code
    # @method playlist_reorder_tracks(playlist, indices, index)
    attach_function :playlist_reorder_tracks, [ Playlist, :array, :int, :int ], :error do |playlist, indices, index|
      indices = Array(indices)

      with_buffer(:int, size: indices.length) do |indices_buffer|
        indices_buffer.write_array_of_int(indices)
        sp_playlist_reorder_tracks(playlist, indices_buffer, indices.length, index)
      end
    end

    # @see #playlist_is_loaded
    # @see #playlist_update_subscribers
    # @note if the playlist is not loaded, the function always return 0.
    # @note if {#playlist_update_subscribers} have not been called, the function always return 0.
    # @param [Playlist] playlist
    # @return [Integer] number of playlist subscribers
    # @method playlist_num_subscribers(playlist)
    attach_function :playlist_num_subscribers, [ Playlist ], :uint

    # @example
    #   subscribers = Spotify.playlist_subscribers(playlist).to_a
    #   puts "Subscribers: ", subscribers.join(", ")
    #
    # @see #playlist_is_loaded
    # @see #playlist_update_subscribers
    # @see Subscribers
    # @note if the playlist is not loaded, the function always return an empty structure.
    # @note if {#playlist_update_subscribers} have not been called, the function always return an empty structure.
    # @param [Playlist] playlist
    # @return [Subscribers]
    # @method playlist_subscribers(playlist)
    attach_function :playlist_subscribers, [ Playlist ], Subscribers.auto_ptr
    attach_function :playlist_subscribers_free, [ Subscribers.by_ref ], :error

    # Request download of the subscribers list.
    #
    # @note the function updates subscribers asynchronously, see {PlaylistCallbacks#subscribers_changed} for callback.
    # @param [Session] session
    # @param [Playlist] playlist
    # @return [Symbol] error code
    # @method playlist_update_subscribers(session, playlist)
    attach_function :playlist_update_subscribers, [ Session, Playlist ], :error

    # @see https://developer.spotify.com/docs/libspotify/12.1.51/group__playlist.html#ga967ad87f0db702513ecda82546f667c5
    # @param [Session] session
    # @param [Playlist] playlist
    # @return [Boolean] true if playlist is loaded in memory, as opposed to only stored on disk.
    # @method playlist_is_in_ram(session, playlist)
    attach_function :playlist_is_in_ram, [ Session, Playlist ], :bool

    # Set if playlist should be loaded into memory, as opposed to only read from on disk.
    #
    # @see https://developer.spotify.com/docs/libspotify/12.1.51/group__playlist.html#ga967ad87f0db702513ecda82546f667c5
    # @param [Session] session
    # @param [Playlist] playlist
    # @param [Boolean] in_ram
    # @return [Symbol] error code
    # @method playlist_set_in_ram(session, playlist, in_ram)
    attach_function :playlist_set_in_ram, [ Session, Playlist, :bool ], :error

    # Instantiate a Playlist from a Link.
    #
    # @param [Session] session
    # @param [Link] link
    # @return [Playlist, nil] playlist, or nil if link was not a valid playlist link
    # @method playlist_create(session, link)
    attach_function :playlist_create, [ Session, Link ], Playlist

    # @see #playlist_is_loaded
    # @see #playlist_set_offline_mode
    # @note if the playlist is not loaded, the function always return :no.
    # @param [Session] session
    # @param [Playlist] playlist
    # @return [Symbol] playlist offline status, one of :no, :yes, :downloading, or :waiting
    # @method playlist_get_offline_status(session, playlist)
    attach_function :playlist_get_offline_status, [ Session, Playlist ], :playlist_offline_status

    # @note if the playlist is not loaded, the function always return 0.
    # @note if the playlist is not marked for offline download, the function always return 0.
    # @param [Session] session
    # @param [Playlist] playlist
    # @return [Integer] percentage of playlist downloaded, 0..100
    # @method playlist_get_offline_download_completed(session, playlist)
    attach_function :playlist_get_offline_download_completed, [ Session, Playlist ], :int

    # Set if playlist should be marked for offline playback.
    #
    # @param [Session] session
    # @param [Playlist] playlist
    # @param [Boolean] offline true if playlist should be downloaded for offline usage
    # @return [Symbol] error code
    # @method playlist_set_offline_mode(session, playlist, offline)
    attach_function :playlist_set_offline_mode, [ Session, Playlist, :bool ], :error

    attach_function :playlist_add_ref, [ Playlist ], :error
    attach_function :playlist_release, [ Playlist ], :error
  end
end
