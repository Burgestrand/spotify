module Spotify
  # Spotify::Struct for Session callbacks.
  #
  # @!method logged_in(session, error)
  #   @param [Session] session
  #   @param [Symbol] error
  # @!method logged_out(session)
  #   @param [Session] session
  # @!method metadata_updated(session)
  #   @param [Session]
  # @!method connection_error(session, error)
  #   @param [Session] session
  #   @param [Symbol] error
  # @!method message_to_user(session, message)
  #   @param [Session] session
  #   @param [String] message
  # @!method notify_main_thread(session)
  #   @param [Session] session
  # @!method music_delivery(session, audio_format, frames_pointer, frames_length)
  #   Frames pointer is pointing to data in the format described by audio format, with interleaved channels:
  #
  #   frames memory (16 bit = 2 byte frames, 2 channels, 3 frames):
  #      00 00 # sample 1, frame 1, channel 1
  #      00 00 # sample 2, frame 1, channel 2
  #      00 00 # sample 3, frame 2, channel 1
  #      00 00 # sample 4, frame 2, channel 2
  #      00 00 # sample 5, frame 3, channel 1
  #      00 00 # sample 6, frame 3, channel 2
  #      # end of data, 3 frames * 2 channels = 6 samples
  #
  #   @param [Session] session
  #   @param [AudioFormat] audio_format
  #   @param [FFI::Pointer] frames_pointer
  #   @param [Integer] frames_length
  #   @return [Integer] number of consumed frames, 0..frames_length
  # @!method play_token_lost(session)
  #   @param [Session] session
  # @!method log_message(session, message)
  #   @param [Session] session
  #   @param [String] message
  # @!method end_of_track(session)
  #   @param [Session]
  # @!method streaming_error(session, error)
  #   @param [Session] session
  #   @param [Symbol] error
  # @!method userinfo_updated(session)
  #   @param [Session] session
  # @!method start_playback(session)
  #   @param [Session] session
  # @!method stop_playback(session)
  #   @param [Session] session
  # @!method get_audio_buffer_stats(session, stats)
  #   @param [Session] session
  #   @param [AudioBufferStats] stats
  # @!method offline_status_updated(session)
  #   @param [Session] session
  # @!method offline_error(session, error)
  #   @param [Session] session
  #   @param [Symbol] error
  # @!method credentials_blob_updated(session, blob)
  #   @param [Session] session
  #   @param [String] blob
  # @!method connectionstate_updated(session)
  #   @param [Session] session
  # @!method scrobble_error(session, error)
  #   @param [Session] session
  #   @param [Symbol] error
  # @!method private_session_mode_changed(session, is_private)
  #   @param [Session] session
  #   @param [Boolean] is_private
  class SessionCallbacks < Spotify::Struct
    layout :logged_in => callback([ Session, APIError ], :void),
           :logged_out => callback([ Session ], :void),
           :metadata_updated => callback([ Session ], :void),
           :connection_error => callback([ Session, APIError ], :void),
           :message_to_user => callback([ Session, UTF8String ], :void),
           :notify_main_thread => callback([ Session ], :void),
           :music_delivery => callback([ Session, AudioFormat.by_ref, :frames, :int ], :int),
           :play_token_lost => callback([ Session ], :void),
           :log_message => callback([ Session, UTF8String ], :void),
           :end_of_track => callback([ Session ], :void),
           :streaming_error => callback([ Session, APIError ], :void),
           :userinfo_updated => callback([ Session ], :void),
           :start_playback => callback([ Session ], :void),
           :stop_playback => callback([ Session ], :void),
           :get_audio_buffer_stats => callback([ Session, AudioBufferStats.by_ref ], :void),
           :offline_status_updated => callback([ Session ], :void),
           :offline_error => callback([ Session, APIError ], :void),
           :credentials_blob_updated => callback([ Session, :string ], :void),
           :connectionstate_updated => callback([ Session ], :void),
           :scrobble_error => callback([ Session, APIError ], :void),
           :private_session_mode_changed => callback([ Session, :bool ], :void)

    # Sane defaults, to avoid {Spotify::API#session_logout} segfaulting.
    DEFAULTS = {
      connection_error: proc {},
      connectionstate_updated: proc {},
      credentials_blob_updated: proc {},
      end_of_track: proc {},
      get_audio_buffer_stats: proc {},
      log_message: proc {},
      logged_in: proc {},
      logged_out: proc {},
      message_to_user: proc {},
      metadata_updated: proc {},
      music_delivery: proc {},
      notify_main_thread: proc {},
      offline_error: proc {},
      offline_status_updated: proc {},
      play_token_lost: proc {},
      private_session_mode_changed: proc {},
      scrobble_error: proc {},
      start_playback: proc {},
      stop_playback: proc {},
      streaming_error: proc {},
      userinfo_updated: proc {},
    }
  end
end
