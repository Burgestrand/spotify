module Spotify
  # FFI::Struct for Audio Format.
  #
  # @attr [:sampletype] sample_type
  # @attr [Fixnum] sample_rate
  # @attr [Fixnum] channels
  class AudioFormat < FFI::Struct
    layout :sample_type => :sampletype,
           :sample_rate => :int,
           :channels => :int
  end

  # FFI::Struct for Audio Buffer Stats.
  #
  # @attr [Fixnum] samples
  # @attr [Fixnum] stutter
  class AudioBufferStats < FFI::Struct
    layout :samples => :int,
           :stutter => :int
  end

  # FFI::Struct for Session callbacks.
  #
  # @attr [callback(Session, :error):void] logged_in
  # @attr [callback(Session):void] logged_out
  # @attr [callback(Session):void] metadata_updated
  # @attr [callback(Session, :error):void] connection_error
  # @attr [callback(Session, UTF8String):void] message_to_user
  # @attr [callback(Session):void] notify_main_thread
  # @attr [callback(Session, AudioFormat, :frames, :int):int] music_delivery
  # @attr [callback(Session):void] play_token_lost
  # @attr [callback(Session, UTF8String):void] log_message
  # @attr [callback(Session):void] end_of_track
  # @attr [callback(Session, :error):void] streaming_error
  # @attr [callback(Session):void] userinfo_updated
  # @attr [callback(Session):void] start_playback
  # @attr [callback(Session):void] stop_playback
  # @attr [callback(Session, AudioBufferStats):void] get_audio_buffer_stats
  # @attr [callback(Session):void] offline_status_updated
  # @attr [callback(Session, :error):void] offline_error
  # @attr [callback(Session, :string):void] credentials_blob_updated
  # @attr [callback(Session):void] connectionstate_updated
  # @attr [callback(Session, :error):void] scrobble_error
  # @attr [callback(Session, :bool):void] private_session_mode_changed
  class SessionCallbacks < FFI::Struct
    layout :logged_in => callback([ Session, :error ], :void),
           :logged_out => callback([ Session ], :void),
           :metadata_updated => callback([ Session ], :void),
           :connection_error => callback([ Session, :error ], :void),
           :message_to_user => callback([ Session, UTF8String ], :void),
           :notify_main_thread => callback([ Session ], :void),
           :music_delivery => callback([ Session, AudioFormat, :frames, :int ], :int),
           :play_token_lost => callback([ Session ], :void),
           :log_message => callback([ Session, UTF8String ], :void),
           :end_of_track => callback([ Session ], :void),
           :streaming_error => callback([ Session, :error ], :void),
           :userinfo_updated => callback([ Session ], :void),
           :start_playback => callback([ Session ], :void),
           :stop_playback => callback([ Session ], :void),
           :get_audio_buffer_stats => callback([ Session, AudioBufferStats ], :void),
           :offline_status_updated => callback([ Session ], :void),
           :offline_error => callback([ Session, :error ], :void),
           :credentials_blob_updated => callback([ Session, :string ], :void),
           :connectionstate_updated => callback([ Session ], :void),
           :scrobble_error => callback([ Session, :error ], :void),
           :private_session_mode_changed => callback([ Session, :bool ], :void)
  end

  # FFI::Struct for Session configuration.
  #
  # @attr [Fixnum] api_version
  # @attr [StringPointer] cache_location
  # @attr [StringPointer] settings_location
  # @attr [size_t] application_key_size
  # @attr [StringPointer] user_agent
  # @attr [StructPointer] callbacks
  # @attr [Pointer] userdata
  # @attr [Fixnum] dont_save_metadata_for_playlists
  # @attr [Fixnum] initially_unload_playlists
  # @attr [Boolean] initially_unload_playlists
  # @attr [StringPointer] device_id
  # @attr [StringPointer] proxy
  # @attr [StringPointer] proxy_username
  # @attr [StringPointer] proxy_password
  # @attr [StringPointer] ca_certs_filename
  # @attr [StringPointer] tracefile
  class SessionConfig < FFI::Struct
    it = {}
    it[:api_version] = :int
    it[:cache_location] = :string_pointer
    it[:settings_location] = :string_pointer
    it[:application_key] = :pointer
    it[:application_key_size] = :size_t
    it[:user_agent] = :string_pointer
    it[:callbacks] = SessionCallbacks.by_ref
    it[:userdata] = :userdata
    it[:compress_playlists] = :bool
    it[:dont_save_metadata_for_playlists] = :bool
    it[:initially_unload_playlists] = :bool
    it[:device_id] = :string_pointer
    it[:proxy] = :string_pointer
    it[:proxy_username] = :string_pointer
    it[:proxy_password] = :string_pointer
    it[:ca_certs_filename] = :string_pointer if Spotify.linux?
    it[:tracefile] = :string_pointer
    layout(it)
  end

  # FFI::Struct for Offline Sync Status
  #
  # @attr [Fixnum] queued_tracks
  # @attr [Fixnum] queued_bytes
  # @attr [Fixnum] done_tracks
  # @attr [Fixnum] done_bytes
  # @attr [Fixnum] copied_tracks
  # @attr [Fixnum] copied_bytes
  # @attr [Fixnum] willnotcopy_tracks
  # @attr [Fixnum] error_tracks
  # @attr [Boolean] syncing
  class OfflineSyncStatus < FFI::Struct
    layout :queued_tracks => :int,
           :queued_bytes => :uint64,
           :done_tracks => :int,
           :done_bytes => :uint64,
           :copied_tracks => :int,
           :copied_bytes => :uint64,
           :willnotcopy_tracks => :int,
           :error_tracks => :int,
           :syncing => :bool
  end

  # FFI::Struct for Playlist callbacks.
  #
  # @attr [callback(Playlist, :array, :int, :int, :userdata):void] tracks_added
  # @attr [callback(Playlist, :array, :int, :userdata):void] tracks_removed
  # @attr [callback(Playlist, :array, :int, :int, :userdata):void] tracks_moved
  # @attr [callback(Playlist, :userdata):void] playlist_renamed
  # @attr [callback(Playlist, :userdata):void] playlist_state_changed
  # @attr [callback(Playlist, :bool, :userdata):void] playlist_update_in_progress
  # @attr [callback(Playlist, :userdata):void] playlist_metadata_updated
  # @attr [callback(Playlist, :int, User, :int, :userdata):void] track_created_changed
  # @attr [callback(Playlist, :int, :bool, :userdata):void] track_seen_changed
  # @attr [callback(Playlist, UTF8String, :userdata):void] description_changed
  # @attr [callback(Playlist, ImageID, :userdata):void] image_changed
  # @attr [callback(Playlist, :int, UTF8String, :userdata):void] track_message_changed
  # @attr [callback(Playlist, :userdata):void] subscribers_changed
  class PlaylistCallbacks < FFI::Struct
    layout :tracks_added => callback([ Playlist, :array, :int, :int, :userdata ], :void),
           :tracks_removed => callback([ Playlist, :array, :int, :userdata ], :void),
           :tracks_moved => callback([ Playlist, :array, :int, :int, :userdata ], :void),
           :playlist_renamed => callback([ Playlist, :userdata ], :void),
           :playlist_state_changed => callback([ Playlist, :userdata ], :void),
           :playlist_update_in_progress => callback([ Playlist, :bool, :userdata ], :void),
           :playlist_metadata_updated => callback([ Playlist, :userdata ], :void),
           :track_created_changed => callback([ Playlist, :int, User, :int, :userdata ], :void),
           :track_seen_changed => callback([ Playlist, :int, :bool, :userdata ], :void),
           :description_changed => callback([ Playlist, UTF8String, :userdata ], :void),
           :image_changed => callback([ Playlist, ImageID, :userdata ], :void),
           :track_message_changed => callback([ Playlist, :int, UTF8String, :userdata ], :void),
           :subscribers_changed => callback([ Playlist, :userdata ], :void)
  end

  # FFI::Struct for Subscribers of a Playlist.
  #
  # @attr [Fixnum] count
  # @attr [Array<Pointer<String>>] subscribers
  class Subscribers < FFI::Struct
    layout :count => :uint,
           :subscribers => [:pointer, 1] # array of pointers to strings

    # Redefined, as the layout of the Struct can only be determined
    # at run-time.
    #
    # @param [FFI::Pointer, Integer] pointer_or_count
    def initialize(pointer_or_count)
      count = if pointer_or_count.is_a?(FFI::Pointer)
        pointer_or_count.read_uint
      else
        pointer_or_count
      end

      layout  = [:count, :uint]
      layout += [:subscribers, [:pointer, count]] if count > 0

      if pointer_or_count.is_a?(FFI::Pointer)
        super(pointer_or_count, *layout)
      else
        super(nil, *layout)
      end
    end
  end

  # FFI::Struct for the PlaylistContainer.
  #
  # @attr [callback(PlaylistContainer, Playlist, :int, :userdata):void] playlist_added
  # @attr [callback(PlaylistContainer, Playlist, :int, :userdata):void] playlist_removed
  # @attr [callback(PlaylistContainer, Playlist, :int, :int, :userdata):void] playlist_moved
  # @attr [callback(PlaylistContainer, :userdata):void] container_loaded
  class PlaylistContainerCallbacks < FFI::Struct
    layout :playlist_added, callback([ PlaylistContainer, Playlist, :int, :userdata ], :void),
           :playlist_removed, callback([ PlaylistContainer, Playlist, :int, :userdata ], :void),
           :playlist_moved, callback([ PlaylistContainer, Playlist, :int, :int, :userdata ], :void),
           :container_loaded, callback([ PlaylistContainer, :userdata ], :void)
  end
end
