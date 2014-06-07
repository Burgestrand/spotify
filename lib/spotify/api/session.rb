module Spotify
  class API
    # @!group Session

    # @example
    #   callbacks = Spotify::SessionCallbacks.new({
    #     connectionstate_updated: proc do |session|
    #       puts "New connection state: #{Spotify.session_connectionstate(session)}."
    #     end,
    #     music_delivery: proc do |session, format, frames, num_frames|
    #       puts "More audio coming through!"
    #     end,
    #   })
    #
    #   config = Spotify::SessionConfig.new({
    #     api_version: Spotify::API_VERSION.to_i,
    #     application_key: File.binread("./spotify_appkey.key"),
    #     cache_location: "",
    #     user_agent: "spotify for ruby",
    #     callbacks: callbacks,
    #   })
    #
    #   # .new cannot return the value of the block, so we use break to cheat out
    #   session = FFI::MemoryPointer.new(Spotify::Session) do |session_pointer|
    #     Spotify.try(:session_create, config, session_pointer)
    #     break Spotify::Session.from_native(session_pointer.read_pointer, nil)
    #   end
    #
    # @note it is *very* important that the callbacks are not garbage collected while they may be called!
    # @param [SessionConfig] config
    # @param [FFI::Pointer<Session>] session_out
    # @return [Symbol] error code
    # @method session_create(session_config, session_out)
    attach_function :session_create, [ SessionConfig.by_ref, :buffer_out ], :error
    attach_function :session_release, [ Session ], :error

    # Tell libspotify to process pending events from the backend.
    #
    # This will download changes and updates from Spotify, while simultaneously also uploading changes
    # made locally, such as tracks added to playlists and more.
    #
    # This method is the cornerstone of libspotify. It should be called frequently to synchronize data.
    # This method is also responsible for calling most callbacks.
    #
    # @example
    #   Spotify.session_process_events(session) # => 1337
    #
    # @param [Session] session
    # @return [Integer] time (in milliseconds) until you should call process_events again
    # @method session_process_events(session)
    attach_function :session_process_events, [ Session, :buffer_out ], :error do |session|
      with_buffer(:int) do |timeout_buffer|
        sp_session_process_events(session, timeout_buffer)
        timeout_buffer.read_int
      end
    end

    # Schedule a login.
    #
    # @see #session_process_events
    # @see #session_relogin
    # @note Login happens in the background. You have to process events a few times before you are logged in.
    # @param [Session] session
    # @param [String] username spotify username, or facebook e-mail
    # @param [String] password spotify password, or facebook password, or nil
    # @param [Boolean] remember_me true if {#session_relogin} should be possible
    # @param [String] password_blob an alternative to password, stored from credentials_blob_updated session callback
    # @return [Symbol] error code
    # @method session_login(session, username, password, remember_me, password_blob)
    attach_function :session_login, [ Session, UTF8String, UTF8String, :bool, UTF8String ], :error

    # Log in a previously remembered login from {#session_login}.
    #
    # You would use this after terminating your application, and later starting it again,
    # assuming {#session_remembered_user} contains a username that is remembered.
    #
    # @see #session_login
    # @see #session_process_events
    # @note You must call {#session_logout} for remembered credentials to be stored.
    # @note Login happens in the background. You have to process events a few times before you are logged in.
    # @param [Session] session
    # @return [Symbol] error code
    # @method session_relogin(session)
    attach_function :session_relogin, [ Session ], :error

    # Forget a previously remembered user.
    #
    # @see #session_relogin
    # @param [Session] session
    # @return [Symbol] error code
    # @method session_forget_me(session)
    attach_function :session_forget_me, [ Session ], :error

    # Retrieve the remembered user from {#session_login}.
    #
    # This is the user that will be logged in if you use {#session_relogin}.
    #
    # @example
    #   Spotify.session_remembered_user(session) # => "Burgestrand"
    #
    # @param [Session] session
    # @return [String, nil] username of the remembered user, or nil if there was none
    # @method session_remembered_user(session)
    attach_function :session_remembered_user, [ Session, :buffer_out, :size_t ], :int do |session|
      username_length = sp_session_remembered_user(session, nil, 0)
      username = with_string_buffer(username_length) do |username_buffer, size|
        sp_session_remembered_user(session, username_buffer, size)
      end
      username unless username.empty?
    end

    # @param [Session] session
    # @return [User, nil] currently logged in user
    # @method session_user(session)
    attach_function :session_user, [ Session ], User

    # Schedule a logout.
    #
    # @note This updates credentials in remember_me from {#session_login} and {#session_forget_me}.
    # @note Logout happen asynchronously. You need to call {#session_process_events} a little while.
    # @param [Session] session
    # @return [Symbol] error code
    # @method session_logout(session)
    attach_function :session_logout, [ Session ], :error

    # @param [Session] session
    # @return [Symbol] current session connection state, one of :logged_out, :logged_in, :disconnected, :undefined, :offline
    # @method session_connectionstate(session)
    attach_function :session_connectionstate, [ Session ], :connectionstate

    # @param [Session] session
    # @return [FFI::Pointer] userdata from config in {#session_create}
    # @method session_userdata(session)
    attach_function :session_userdata, [ Session ], :userdata

    # Set the allowed disk cache size used by libspotify.
    #
    # @param [Session] session
    # @param [Integer] cache_size maximum cache size in megabytes, 0 means libspotify automatically resize cache as needed
    # @return [Symbol] error code
    # @method session_set_cache_size(session, cache_size)
    attach_function :session_set_cache_size, [ Session, :size_t ], :error

    # Load the specified track for playback.
    #
    # When the the function returns, the track will have been loaded assuming there as no error.
    #
    # @param [Session] session
    # @param [Track] track
    # @return [Symbol] error code
    # @method session_player_load(session, track)
    attach_function :session_player_load, [ Session, Track ], :error

    # Seek to position in the currently loaded track.
    #
    # @see #session_player_load
    # @param [Session] session
    # @param [Integer] position in milliseconds
    # @return [Symbol] error code
    # @method session_player_seek(session, position)
    attach_function :session_player_seek, [ Session, :int ], :error

    # Play or pause the currently loaded track.
    #
    # This will start delivery of audio frames to the music_delivery callback in {#session_create}.
    # However, playback should wait until {SessionCallbacks#start_playback} callback is called by libspotify.
    #
    # @see #session_player_load
    # @param [Session] session
    # @param [Boolean] play if set to true, playback will be resumed, if set to false playback will be paused
    # @return [Symbol] error code
    # @method session_player_play(session, play)
    attach_function :session_player_play, [ Session, :bool ], :error

    # Stop playback and clear the currently loaded track.
    #
    # @see #session_player_load
    # @param [Session] session
    # @return [Symbol] error code
    # @method session_player_unload(session)
    attach_function :session_player_unload, [ Session ], :error

    # Tell libspotify to start preloading a track so that {#session_player_load} has less work to do.
    #
    # This could be done towards the end of a track in a queue, before starting playing the next.
    #
    # @note prefetching is only possible if using a cache from config in {#session_create}
    # @param [Session] session
    # @param [Track] track
    # @return [Symbol] error code
    # @method session_player_prefetch(session, track)
    attach_function :session_player_prefetch, [ Session, Track ], :error

    # @note if not logged in, the function always return nil.
    # @param [Session] session
    # @return [PlaylistContainer, nil] playlist container for currently logged in user
    # @method session_playlistcontainer(session)
    attach_function :session_playlistcontainer, [ Session ], PlaylistContainer

    # @note if not logged in, the function always return nil.
    # @param [Session] session
    # @return [Playlist] inbox playlist for currently logged in user (playlist where items sent by other users are posted to)
    # @method session_inbox_create(session)
    attach_function :session_inbox_create, [ Session ], Playlist

    # @note if not logged in, the function always return nil.
    # @param [Session] session
    # @return [Playlist, nil] starred playlist for currently logged in user
    # @method session_starred_create(session)
    attach_function :session_starred_create, [ Session ], Playlist

    # @note if not logged in, the function always return nil.
    # @param [Session] session
    # @param [String] username canonical username of user
    # @return [Playlist, nil] starred playlist for the specified user
    # @method session_starred_for_user_create(session, username)
    attach_function :session_starred_for_user_create, [ Session, UTF8String ], Playlist

    # @note if not logged in, the function always return nil.
    # @param [Session] session
    # @param [String] username canonical username of user
    # @return [PlaylistContainer, nil] published playlists container for the specified user
    # @method session_publishedcontainer_for_user_create(session, username)
    attach_function :session_publishedcontainer_for_user_create, [ Session, UTF8String ], PlaylistContainer

    # Set preferred bitrate for music streaming.
    #
    # @param [Session] session
    # @param [Symbol] bitrate one of :160k, :320k, :96k
    # @return [Symbol] error code
    # @method session_preferred_bitrate(session, bitrate)
    attach_function :session_preferred_bitrate, [ Session, :bitrate ], :error

    # Set current connection type.
    #
    # @see #session_set_connection_rules
    # @param [Session] session
    # @param [Symbol] type one of :unknown, :none, :mobile, :mobile_roaming, :wifi, :wired
    # @return [Symbol] error code
    # @method session_set_connection_type(session, type)
    attach_function :session_set_connection_type, [ Session, :connection_type ], :error

    # Set rules for how libspotify connects to Spotify servers and synchronizes offline content.
    #
    # @example
    #   online_mode = Spotify::Util.enum_value!(:network, :connection_rules)
    #   over_wifi = Spotify::Util.enum_value!(:allow_sync_over_wifi, :connection_rules)
    #   Spotify.session_set_connection_rules($session, online_mode | over_wifi) # => :ok
    #
    # @see #session_set_connection_type
    # @param [Session] session
    # @param [Symbol] rules any of :network, :network_if_roaming, :allow_sync_over_mobile, :allow_sync_over_wifi
    # @return [Symbol] error code
    # @method session_set_connection_rules(session, rules)
    attach_function :session_set_connection_rules, [ Session, :connection_rules ], :error

    # @param [Session] session
    # @return [Integer] total number of tracks left to sync before all offline content has downloaded
    # @method offline_tracks_to_sync(session)
    attach_function :offline_tracks_to_sync, [ Session ], :int

    # @param [Session] session
    # @return [Integer] total number of playlists marked for offline synchronization
    # @method offline_num_playlists(session)
    attach_function :offline_num_playlists, [ Session ], :int

    # @example
    #   status = Spotify::OfflineSyncStatus.new
    #   Spotify.offline_sync_get_status(session, status)
    #   p status.to_h # => { queued_tracks: 0, queued_bytes: 0, … }
    #
    # @param [Session] session
    # @param [OfflineSyncStatus] status
    # @return [Boolean] true if offline synching is enabled
    # @method offline_sync_get_status(session, offline_sync_status)
    attach_function :offline_sync_get_status, [ Session, OfflineSyncStatus.by_ref ], :bool

    # @param [Session] session
    # @return [Integer] remaining time (in seconds) until offline key store expires and user is required to relogin
    # @method offline_time_left(session)
    attach_function :offline_time_left, [ Session ], :int

    # @note if not logged in, the function always return "ZZ".
    # @param [Session] session
    # @return [String] currently logged in user's country code
    # @method session_user_country(session)
    attach_function :session_user_country, [ Session ], CountryCode

    # Set preferred bitrate for offline playback.
    #
    # @param [Session] session
    # @param [Symbol] bitrate one of :160k, :320k, :96k
    # @param [Boolean] resync true if libspotify should redownload tracks with new bitrate
    # @return [Symbol] error code
    # @method session_preferred_offline_bitrate(session, bitrate, resync)
    attach_function :session_preferred_offline_bitrate, [ Session, :bitrate, :bool ], :error

    # Set volume normalization.
    #
    # @param [Session] session
    # @param [Boolean] normalize true if libspotify should attempt to normalize sound volume
    # @return [Symbol] error code
    # @method session_set_volume_normalization(session, normalize)
    attach_function :session_set_volume_normalization, [ Session, :bool ], :error

    # @see #session_set_volume_normalization
    # @param [Session] session
    # @return [Boolean] current volume normalization setting
    # @method session_get_volume_normalization(session)
    attach_function :session_get_volume_normalization, [ Session ], :bool

    # Force libspotify to write all disk-stored data to disk immediately.
    #
    # @note libspotify does this periodically by itself, and on logout, so usually this is not needed.
    # @param [Session] session
    # @return [Symbol] error code
    # @method session_flush_caches(session)
    attach_function :session_flush_caches, [ Session ], :error

    # @note if not logged in, the function always return an empty string.
    # @param [Session] session
    # @return [String] canonical name for currently logged in user
    # @method session_user_name(session)
    attach_function :session_user_name, [ Session ], UTF8String

    # Set if private session is enabled.
    #
    # This disables sharing of what the user is listening to with Spotify Social, Facebook, and LastFM.
    # The private session will automatically revert back to normal state after a period of inactivity (6 hours?).
    #
    # @param [Session] session
    # @param [Boolean] enabled true if playback should be private
    # @return [Symbol] error code
    # @method session_set_private_session(session, enabled)
    attach_function :session_set_private_session, [ Session, :bool ], :error

    # @see #session_set_private_session
    # @param [Session] session
    # @return [Boolean] true if private session is enabled
    # @method session_is_private_session(session)
    attach_function :session_is_private_session, [ Session ], :bool

    # Set if scrobbling should be enabled.
    #
    # @note changing the global settings are currently not supported.
    # @param [Session] session
    # @param [Symbol] social_provider one of :spotify, :facebook, or :lastfm
    # @param [Symbol] scrobbling_state one of :use_global_setting, :local_enabled, :local_disabled, :global_enabled, :global_disabled
    # @return [Symbol] error code
    # @method session_set_scrobbling(session, social_provider, scrobbling_state)
    attach_function :session_set_scrobbling, [ Session, :social_provider, :scrobbling_state ], :error

    # Retrieve the scrobbling state.
    #
    # This makes it possible to find out if scrobbling is locally overrided or if global setting is used.
    #
    # @example
    #   Spotify.session_is_scrobbling(session, :spotify) # => :global_enabled
    #
    # @param [Session] session
    # @param [Symbol] social_provider
    # @return [Symbol] current scrobbling state for the social provider
    # @method session_is_scrobbling(session, social_provider)
    attach_function :session_is_scrobbling, [ Session, :social_provider, :buffer_out ], :error do |session, social_provider|
      with_buffer(:int) do |state_buffer|
        error = sp_session_is_scrobbling(session, social_provider, state_buffer)
        enum_type(:scrobbling_state)[state_buffer.read_int] if error == :ok
      end
    end

    # Retrieve if it is possible to scrobble to the social provider.
    #
    # @example
    #
    # @note currently this setting is only relevant to the facebook provider
    # @param [Session] session
    # @param [Symbol] social_provider
    # @return [Boolean] true if scrobbling is possible
    # @method session_is_scrobbling_possible(session, social_provider)
    attach_function :session_is_scrobbling_possible, [ Session, :social_provider, :buffer_out ], :error do |session, social_provider|
      with_buffer(:char) do |possible_buffer|
        error = sp_session_is_scrobbling_possible(session, social_provider, possible_buffer)
        possible_buffer.read_char != 0 if error == :ok
      end
    end

    # Set the user's credentials for a social provider.
    #
    # @see #session_set_scrobbling
    # @note currently this is only relevenat for LastFm
    # @note set scrobbling state to true to force an authentication attempt, if it fails the scrobble_error callback will be invoked
    # @param [Session] session
    # @param [Symbol] social_provider
    # @param [String] username
    # @param [String] password
    # @return [Symbol] error code
    # @method session_set_social_credentials(session, social_provider, username, password)
    attach_function :session_set_social_credentials, [ Session, :social_provider, UTF8String, UTF8String ], :error
  end
end
