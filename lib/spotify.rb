# coding: utf-8
require 'ffi'
require 'spotify/version'

# FFI wrapper around libspotify.
# 
# See official documentation for more detailed documentation about
# functions and their behavior.
# 
# @see http://developer.spotify.com/en/libspotify/docs/
module Spotify
  extend FFI::Library
  ffi_lib ['libspotify', '/Library/Frameworks/libspotify.framework/libspotify']
  
  # libspotify API version
  # @return [Fixnum]
  API_VERSION = VERSION.split('.').first.to_i
  
  #
  # Error
  # 
  # @see http://developer.spotify.com/en/libspotify/docs/group__error.html
  enum :error, [:ok, :bad_api_version, :api_initialization_failed,
               :track_not_playable, :resource_not_loaded,
               :bad_application_key, :bad_username_or_password,
               :user_banned, :unable_to_contact_server,
               :client_too_old, :other_permanent, :bad_user_agent,
               :missing_callback, :invalid_indata,
               :index_out_of_range, :user_needs_premium,
               :other_transient, :is_loading, :no_stream_available,
               :permission_denied, :inbox_is_full, :no_cache,
               :no_such_user]
  
  attach_function :error_message, :sp_error_message, [ :error ], :string
  
  #
  # Audio
  # 
  # @see http://developer.spotify.com/en/libspotify/docs/group__session.html
  enum :sampletype, [:int16_native_endian]
  enum :bitrate, %w(160k 320k)
  
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
end