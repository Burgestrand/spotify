module Spotify
  # Spotify::Struct for Session callbacks.
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
  class SessionCallbacks < Spotify::Struct
    layout :logged_in => callback([ Session, :error ], :void),
           :logged_out => callback([ Session ], :void),
           :metadata_updated => callback([ Session ], :void),
           :connection_error => callback([ Session, :error ], :void),
           :message_to_user => callback([ Session, UTF8String ], :void),
           :notify_main_thread => callback([ Session ], :void),
           :music_delivery => callback([ Session, AudioFormat.by_ref, :frames, :int ], :int),
           :play_token_lost => callback([ Session ], :void),
           :log_message => callback([ Session, UTF8String ], :void),
           :end_of_track => callback([ Session ], :void),
           :streaming_error => callback([ Session, :error ], :void),
           :userinfo_updated => callback([ Session ], :void),
           :start_playback => callback([ Session ], :void),
           :stop_playback => callback([ Session ], :void),
           :get_audio_buffer_stats => callback([ Session, AudioBufferStats.by_ref ], :void),
           :offline_status_updated => callback([ Session ], :void),
           :offline_error => callback([ Session, :error ], :void),
           :credentials_blob_updated => callback([ Session, :string ], :void),
           :connectionstate_updated => callback([ Session ], :void),
           :scrobble_error => callback([ Session, :error ], :void),
           :private_session_mode_changed => callback([ Session, :bool ], :void)
  end
end
