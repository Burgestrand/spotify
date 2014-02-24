module Spotify
  class API
    # @!group Playlist

    # @param [Playlist] playlist
    # @return [Boolean] true if playlist is loaded
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
    attach_function :playlist_add_callbacks, [ Playlist, PlaylistCallbacks.by_ref, :userdata ], :error

    # Remove playlist callbacks previously added with {#playlist_add_callbacks}.
    #
    # @see #playlist_add_callbacks
    # @param [Playlist] playlist
    # @param [PlaylistCallbacks] playlist_callbacks
    # @param [FFI::Pointer] userdata
    # @return [Symbol] error code
    attach_function :playlist_remove_callbacks, [ Playlist, PlaylistCallbacks.by_ref, :userdata ], :error

    # @see #playlist_track
    # @note if playlist is not loaded, the function always return 0.
    # @param [Playlist] playlist
    # @return [Integer] number of tracks in the playlist
    attach_function :playlist_num_tracks, [ Playlist ], :int

    # @see #playlist_num_tracks
    # @note if index is out of range, the function always return nil.
    # @param [Playlist] playlist
    # @param [Integer] index number between 0...{#playlist_num_tracks}
    # @return [Track, nil] track at index
    attach_function :playlist_track, [ Playlist, :int ], Track

    # @see #playlist_num_tracks
    # @note if index is out of range, the function always return -1.
    # @param [Playlist] playlist
    # @param [Integer] index number between 0...{#playlist_num_tracks}
    # @return [Integer] time in seconds since unix epoch that track was added at index in the playlist
    attach_function :playlist_track_create_time, [ Playlist, :int ], :int

    # @see #playlist_num_tracks
    # @note if index is out of range, the function always return nil.
    # @param [Playlist] playlist
    # @param [Integer] index number between 0...{#playlist_num_tracks}
    # @return [User, nil] user that added the track at index in the playlist
    attach_function :playlist_track_creator, [ Playlist, :int ], User

    # @see #playlist_num_tracks
    # @see #playlist_track_set_seen
    # @note if index is out of range, the function always return false.
    # @param [Playlist] playlist
    # @param [Integer] index number between 0...{#playlist_num_tracks}
    # @return [Boolean] true if playlist has been marked as seen with {#playlist_track_set_seen}.
    attach_function :playlist_track_seen, [ Playlist, :int ], :bool

    # Set `seen` flag on track. The flag can be retrieved by {#playlist_track_seen}.
    #
    # @see #playlist_num_tracks
    # @see #playlist_track_seen
    # @param [Playlist] playlist
    # @param [Integer] index number between 0...{#playlist_num_tracks}
    # @param [Boolean] seen
    # @return [Symbol] error code
    attach_function :playlist_track_set_seen, [ Playlist, :int, :bool ], :error

    # @see #playlist_num_tracks
    # @note if index is out of range, the function always return nil.
    # @param [Playlist] playlist
    # @param [Integer] index number between 0...{#playlist_num_tracks}
    # @return [String] message attached to a playlist item
    attach_function :playlist_track_message, [ Playlist, :int ], UTF8String

    # @see #playlist_is_loaded
    # @note if playlist is not loaded, the function always return an empty string.
    # @param [Playlist] playlist
    # @return [String] name of the playlist
    attach_function :playlist_name, [ Playlist ], UTF8String

    # Rename the playlist.
    #
    # @see #playlist_is_loaded
    # @note if playlist is not loaded, the function always return :permission_denied.
    # @param [Playlist] playlist
    # @param [String] new_name new name of the playlist
    # @return [Symbol] error code
    attach_function :playlist_rename, [ Playlist, UTF8String ], :error

    # @param [Playlist] playlist
    # @return [User] owner of the playlist
    attach_function :playlist_owner, [ Playlist ], User

    # @see #playlist_is_loaded
    # @see #playlist_set_collaborative
    # @note if {#playlist_set_collaborative} was used, the final value will not be
    #       visible until after libspotify has negotiated with Spotify backend.
    # @note if playlist is not loaded, the function always return false.
    # @param [Playlist] playlist
    # @return [Boolean] true if the playlist is collaborative, i.e. editable by others.
    attach_function :playlist_is_collaborative, [ Playlist ], :bool

    # Set collaborative status on a playlist.
    #
    # @see #playlist_is_collaborative
    # @note the function always return :ok.
    # @param [Playlist] playlist
    # @param [Boolean] collaborative
    # @return [Symbol] error code
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
    attach_function :playlist_set_autolink_tracks, [ Playlist, :bool ], :error

    # @see #playlist_is_loaded
    # @note if the playlist is not loaded, the function always return nil.
    # @param [Playlist] playlist
    # @return [String, nil] playlist description, if available
    attach_function :playlist_get_description, [ Playlist ], UTF8String

    # Read playlist image ID, and return wether playlist had image or not.
    #
    # @example
    #  image_id = FFI::MemoryPointer.new(Spotify::ImageID) do |image_id_ptr|
    #    image_id = if Spotify.playlist_get_image(playlist, image_id_ptr)
    #      Spotify::ImageID.from_native(image_id_ptr, nil)
    #    end
    #    break image_id
    #  end
    #
    # @see #playlist_is_loaded
    # @note if the playlist is not loaded, the function always return false.
    # @param [Playlist] playlist
    # @param [FFI::Pointer] image_id output parameter for an image id to give to {#image_create}
    # @return [Boolean] true if the playlist had an image
    attach_function :playlist_get_image, [ Playlist, :buffer_out ], :bool

    # @see #playlist_is_loaded
    # @note if the playlist is not loaded, the function always return true.
    # @param [Playlist] playlist
    # @return [Boolean] true if the playlist has local changes that have not yet been acknowledged by Spotify backend
    attach_function :playlist_has_pending_changes, [ Playlist ], :bool

    # Add tracks to the playlist.
    #
    # @example
    #   tracks = [track, track]
    #   tracks_pointer = FFI::MemoryPointer.new(Spotify::Track, tracks.length)
    #   index = 0
    #   Spotify.playlist_add_tracks(playlist, tracks_pointer, tracks.length, index, session) # => :ok
    #
    # @see #playlist_is_loaded
    # @note if the playlist is not loaded, the function always return an error.
    # @param [Playlist] playlist
    # @param [FFI::Pointer] tracks_pointer pointer to array of track pointers
    # @param [Integer] tracks_pointer_count number of tracks to add
    # @param [Integer] offset starting index to add tracks from
    # @return [Symbol] error code
    attach_function :playlist_add_tracks, [ Playlist, :array, :int, :int, Session ], :error

    # Remove tracks from the playlist at the given indices.
    #
    # @example
    #   indices = [1, 3]
    #   indices_pointer = FFI::MemoryPointer.new(:int, indices.length)
    #   indices_pointer.write_array_of_int(indices)
    #   Spotify.playlist_remove_tracks(playlist, indices_pointer, indices.length) # => :ok
    #
    # @see #playlist_is_loaded
    # @note if the playlist is not loaded, the function always return an error.
    # @note any index in indices_pointer must exist at most once, i.e. [0,1,2] is valid, [0,0,1] is not.
    # @param [Playlist] playlist
    # @param [FFI::Pointer] indices_pointer pointer to array of track indices
    # @param [Integer] indices_pointer_count number of indices
    # @return [Symbol] error code
    attach_function :playlist_remove_tracks, [ Playlist, :array, :int ], :error

    # Move tracks at the given indices to position index and forward.
    #
    # @example
    #   indices = [1, 3]
    #   indices_pointer = FFI::MemoryPointer.new(:int, indices.length)
    #   indices_pointer.write_array_of_int(indices)
    #   index = Spotify.playlist_num_tracks(playlist)
    #   Spotify.playlist_reorder_tracks(playlist, indices_pointer, indices.length, index) # => :ok
    #
    # @see #playlist_is_loaded
    # @note if the playlist is not loaded, the function always return an error.
    # @note any index in indices_pointer must exist at most once, i.e. [0,1,2] is valid, [0,0,1] is not.
    # @param [Playlist] playlist
    # @param [FFI::Pointer] indices_pointer pointer to array of track indices
    # @param [Integer] indices_pointer_count number of indices
    # @param [Integer] index starting position of tracks to be placed at, number between 0..{#playlist_num_tracks}
    # @return [Symbol] error code
    attach_function :playlist_reorder_tracks, [ Playlist, :array, :int, :int ], :error

    # @see #playlist_is_loaded
    # @see #playlist_update_subscribers
    # @note if the playlist is not loaded, the function always return 0.
    # @note if {#playlist_update_subscribers} have not been called, the function always return 0.
    # @param [Playlist] playlist
    # @return [Integer] number of playlist subscribers
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
    attach_function :playlist_subscribers, [ Playlist ], Subscribers.auto_ptr
    attach_function :playlist_subscribers_free, [ Subscribers.by_ref ], :error

    # Request download of the subscribers list.
    #
    # @note the function updates subscribers asynchronously, see {PlaylistCallbacks#subscribers_changed} for callback.
    # @param [Session] session
    # @param [Playlist] playlist
    # @return [Symbol] error code
    attach_function :playlist_update_subscribers, [ Session, Playlist ], :error

    # @see https://developer.spotify.com/docs/libspotify/12.1.51/group__playlist.html#ga967ad87f0db702513ecda82546f667c5
    # @param [Session] session
    # @param [Playlist] playlist
    # @return [Boolean] true if playlist is loaded in memory, as opposed to only stored on disk.
    attach_function :playlist_is_in_ram, [ Session, Playlist ], :bool

    # Set if playlist should be loaded into memory, as opposed to only read from on disk.
    #
    # @see https://developer.spotify.com/docs/libspotify/12.1.51/group__playlist.html#ga967ad87f0db702513ecda82546f667c5
    # @param [Session] session
    # @param [Playlist] playlist
    # @param [Boolean] in_ram
    # @return [Symbol] error code
    attach_function :playlist_set_in_ram, [ Session, Playlist, :bool ], :error

    # Instantiate a Playlist from a Link.
    #
    # @param [Session] session
    # @param [Link] link
    # @return [Playlist, nil] playlist, or nil if link was not a valid playlist link
    attach_function :playlist_create, [ Session, Link ], Playlist

    # @see #playlist_is_loaded
    # @see #playlist_set_offline_mode
    # @note if the playlist is not loaded, the function always return :no.
    # @param [Session] session
    # @param [Playlist] playlist
    # @return [Symbol] playlist offline status, one of :no, :yes, :downloading, or :waiting
    attach_function :playlist_get_offline_status, [ Session, Playlist ], :playlist_offline_status

    # @note if the playlist is not loaded, the function always return 0.
    # @note if the playlist is not marked for offline download, the function always return 0.
    # @param [Session] session
    # @param [Playlist] playlist
    # @return [Integer] percentage of playlist downloaded, 0..100
    attach_function :playlist_get_offline_download_completed, [ Session, Playlist ], :int

    # Set if playlist should be marked for offline playback.
    #
    # @param [Session] session
    # @param [Playlist] playlist
    # @param [Boolean] offline true if playlist should be downloaded for offline usage
    # @return [Symbol] error code
    attach_function :playlist_set_offline_mode, [ Session, Playlist, :bool ], :error

    attach_function :playlist_add_ref, [ Playlist ], :error
    attach_function :playlist_release, [ Playlist ], :error
  end
end
