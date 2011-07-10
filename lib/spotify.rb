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

  # Data converter for boolean struct fields.
  #
  # @see https://github.com/ffi/ffi/issues/114
  module Bool
    extend FFI::DataConverter
    native_type FFI::Type::UCHAR

    class << self
      def to_native(value, ctx)
        value == true ? 1 : 0
      end

      def from_native(value, ctx)
        (value & 1) != 0
      end
    end
  end

  # libspotify API version
  # @return [Fixnum]
  API_VERSION = VERSION.split('.').first.to_i

  # Aliases to Spotify types
  typedef :pointer, :frames
  typedef :pointer, :session
  typedef :pointer, :track
  typedef :pointer, :user
  typedef :pointer, :playlistcontainer
  typedef :pointer, :playlist
  typedef :pointer, :link
  typedef :pointer, :album
  typedef :pointer, :artist
  typedef :pointer, :search
  typedef :pointer, :image
  typedef :pointer, :albumbrowse
  typedef :pointer, :artistbrowse
  typedef :pointer, :toplistbrowse
  typedef :pointer, :inbox

  typedef :pointer, :userdata
  typedef :pointer, :image_id
  typedef :pointer, :array

  #
  # Error
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__error.html

  #
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

  # @macro [attach] attach_function
  #
  # Calls +$2+. See source for actual parameters.
  #
  # @method $1($3)
  # @return [$4]
  attach_function :error_message, :sp_error_message, [ :error ], :string

  #
  # Audio
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__session.html

  #
  enum :sampletype, [:int16_native_endian]
  enum :bitrate, %w(160k 320k 96k).map(&:to_sym)

  # FFI::Struct for Audio Format.
  #
  # @attr [:sampletype] sample_type
  # @attr [Fixnum] sample_rate
  # @attr [Fixnum] channels
  class AudioFormat < FFI::Struct
    layout :sample_type, :sampletype,
           :sample_rate, :int,
           :channels, :int
  end

  # FFI::Struct for Audio Buffer Stats.
  #
  # @attr [Fixnum] samples
  # @attr [Fixnum] stutter
  class AudioBufferStats < FFI::Struct
    layout :samples, :int,
           :stutter, :int
  end

  #
  # Session
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__session.html

  # FFI::Struct for Session callbacks.
  #
  # @attr [callback(:session, :error):void] logged_in
  # @attr [callback(:session):void] logged_out
  # @attr [callback(:session):void] metadata_updated
  # @attr [callback(:session, :error):void] connection_error
  # @attr [callback(:session, :string):void] message_to_user
  # @attr [callback(:session):void] notify_main_thread
  # @attr [callback(:session, AudioFormat, :frames, :int):int] music_delivery
  # @attr [callback(:session):void] play_token_lost
  # @attr [callback(:session, :string):void] log_message
  # @attr [callback(:session):void] end_of_track
  # @attr [callback(:session, :error):void] streaming_error
  # @attr [callback(:session):void] userinfo_updated
  # @attr [callback(:session):void] start_playback
  # @attr [callback(:session):void] stop_playback
  # @attr [callback(:session, AudioBufferStats):void] get_audio_buffer_stats
  # @attr [callback(:session)::void] offline_status_updated
  class SessionCallbacks < FFI::Struct
    layout :logged_in, callback([ :session, :error ], :void),
           :logged_out, callback([ :session ], :void),
           :metadata_updated, callback([ :session ], :void),
           :connection_error, callback([ :session, :error ], :void),
           :message_to_user, callback([ :session, :string ], :void),
           :notify_main_thread, callback([ :session ], :void),
           :music_delivery, callback([ :session, AudioFormat, :frames, :int ], :int),
           :play_token_lost, callback([ :session ], :void),
           :log_message, callback([ :session, :string ], :void),
           :end_of_track, callback([ :session ], :void),
           :streaming_error, callback([ :session, :error ], :void),
           :userinfo_updated, callback([ :session ], :void),
           :start_playback, callback([ :session ], :void),
           :stop_playback, callback([ :session ], :void),
           :get_audio_buffer_stats, callback([ :session, AudioBufferStats ], :void),
           :offline_status_updated, callback([ :session ], :void)
  end

  # FFI::Struct for Session configuration.
  #
  # @attr [Fixnum] api_version
  # @attr [Pointer] cache_location
  # @attr [Pointer] settings_location
  # @attr [size_t] application_key_size
  # @attr [Pointer] user_agent
  # @attr [Pointer] callbacks
  # @attr [Pointer] userdata
  # @attr [Fixnum] dont_save_metadata_for_playlists
  # @attr [Fixnum] initially_unload_playlists
  class SessionConfig < FFI::Struct
    layout :api_version, :int,
           :cache_location, :pointer,
           :settings_location, :pointer,
           :application_key, :pointer,
           :application_key_size, :size_t,
           :user_agent, :pointer,
           :callbacks, SessionCallbacks,
           :userdata, :userdata,
           :compress_playlists, Bool,
           :dont_save_metadata_for_playlists, Bool,
           :initially_unload_playlists, Bool
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
  # @attr [Fixnum] syncing
  class OfflineSyncStatus < FFI::Struct
    layout :queued_tracks, :int,
           :queued_bytes, :uint64,
           :done_tracks, :int,
           :done_bytes, :uint64,
           :copied_tracks, :int,
           :copied_bytes, :uint64,
           :willnotcopy_tracks, :int,
           :error_tracks, :int,
           :syncing, Bool
  end

  #
  enum :connectionstate, [:logged_out, :logged_in, :disconnected, :undefined]

  #
  enum :connection_type, [:unknown, :none, :mobile, :mobile_roaming, :wifi, :wired]

  #
  enum :connection_rules, [:network               , 0x1,
                           :network_if_roaming    , 0x2,
                           :allow_sync_over_mobile, 0x4,
                           :allow_sync_over_wifi  , 0x8]

  attach_function :session_create, :sp_session_create, [ SessionConfig, :pointer ], :error, :blocking => true
  attach_function :session_release, :sp_session_release, [ :session ], :void

  attach_function :session_process_events, :sp_session_process_events, [ :session, :pointer ], :void, :blocking => true
  attach_function :session_login, :sp_session_login, [ :session, :string, :string ], :void, :blocking => true

  attach_function :session_user, :sp_session_user, [ :session ], :user
  attach_function :session_logout, :sp_session_logout, [ :session ], :void
  attach_function :session_connectionstate, :sp_session_connectionstate, [ :session ], :connectionstate
  attach_function :session_userdata, :sp_session_userdata, [ :session ], :userdata
  attach_function :session_set_cache_size, :sp_session_set_cache_size, [ :session, :size_t ], :void
  attach_function :session_player_load, :sp_session_player_load, [ :session, :track ], :error
  attach_function :session_player_seek, :sp_session_player_seek, [ :session, :int ], :void
  attach_function :session_player_play, :sp_session_player_play, [ :session, :bool ], :void
  attach_function :session_player_unload, :sp_session_player_unload, [ :session ], :void
  attach_function :session_player_prefetch, :sp_session_player_prefetch, [ :session, :track ], :error
  attach_function :session_playlistcontainer, :sp_session_playlistcontainer, [ :session ], :playlistcontainer
  attach_function :session_inbox_create, :sp_session_inbox_create, [ :session ], :playlist
  attach_function :session_starred_create, :sp_session_starred_create, [ :session ], :playlist
  attach_function :session_starred_for_user_create, :sp_session_starred_for_user_create, [ :session, :string ], :playlist
  attach_function :session_publishedcontainer_for_user_create, :sp_session_publishedcontainer_for_user_create, [ :playlist, :string ], :playlistcontainer
  attach_function :session_preferred_bitrate, :sp_session_preferred_bitrate, [ :session, :bitrate ], :void
  attach_function :session_num_friends, :sp_session_num_friends, [ :session ], :int
  attach_function :session_friend, :sp_session_friend, [ :session, :int ], :user

  attach_function :session_set_connection_type, :sp_session_set_connection_type, [ :session, :connection_type ], :void
  attach_function :session_set_connection_rules, :sp_session_set_connection_rules, [ :session, :connection_rules ], :void
  attach_function :offline_tracks_to_sync, :sp_offline_tracks_to_sync, [ :session ], :int
  attach_function :offline_num_playlists, :sp_offline_num_playlists, [ :session ], :int
  attach_function :offline_sync_get_status, :sp_offline_sync_get_status, [ :session, OfflineSyncStatus ], :void
  attach_function :session_user_country, :sp_session_user_country, [ :session ], :int
  attach_function :session_preferred_offline_bitrate, :sp_session_preferred_offline_bitrate, [ :session, :bitrate, :bool ], :void

  #
  # Link
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__link.html

  #
  enum :linktype, [:invalid, :track, :album, :artist, :search,
                   :playlist, :profile, :starred, :localtrack, :image]

  attach_function :link_create_from_string, :sp_link_create_from_string, [ :string ], :link
  attach_function :link_create_from_track, :sp_link_create_from_track, [ :track, :int ], :link
  attach_function :link_create_from_album, :sp_link_create_from_album, [ :album ], :link
  attach_function :link_create_from_artist, :sp_link_create_from_artist, [ :artist ], :link
  attach_function :link_create_from_search, :sp_link_create_from_search, [ :search ], :link
  attach_function :link_create_from_playlist, :sp_link_create_from_playlist, [ :playlist ], :link
  attach_function :link_create_from_artist_portrait, :sp_link_create_from_artist_portrait, [ :artist, :int ], :link
  attach_function :link_create_from_album_cover, :sp_link_create_from_album_cover, [ :album ], :link
  attach_function :link_create_from_image, :sp_link_create_from_image, [ :image ], :link
  attach_function :link_create_from_user, :sp_link_create_from_user, [ :user ], :link
  attach_function :link_as_string, :sp_link_as_string, [ :link, :buffer_out, :int ], :int
  attach_function :link_type, :sp_link_type, [ :link ], :linktype
  attach_function :link_as_track, :sp_link_as_track, [ :link ], :track
  attach_function :link_as_track_and_offset, :sp_link_as_track_and_offset, [ :link, :pointer ], :track
  attach_function :link_as_album, :sp_link_as_album, [ :link ], :album
  attach_function :link_as_artist, :sp_link_as_artist, [ :link ], :artist
  attach_function :link_as_user, :sp_link_as_user, [ :link ], :user

  attach_function :link_add_ref, :sp_link_add_ref, [ :link ], :void
  attach_function :link_release, :sp_link_release, [ :link ], :void

  #
  # Tracks
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__track.html

  #
  attach_function :track_is_loaded, :sp_track_is_loaded, [ :track ], :bool
  attach_function :track_error, :sp_track_error, [ :track ], :error
  attach_function :track_is_available, :sp_track_is_available, [ :session, :track ], :bool
  attach_function :track_is_local, :sp_track_is_local, [ :session, :track ], :bool
  attach_function :track_is_autolinked, :sp_track_is_autolinked, [ :session, :track ], :bool
  attach_function :track_is_starred, :sp_track_is_starred, [ :session, :track ], :bool
  attach_function :track_set_starred, :sp_track_set_starred, [ :session, :array, :int, :bool ], :void
  attach_function :track_num_artists, :sp_track_num_artists, [ :track ], :int
  attach_function :track_artist, :sp_track_artist, [ :track, :int ], :artist
  attach_function :track_album, :sp_track_album, [ :track ], :album
  attach_function :track_name, :sp_track_name, [ :track ], :string
  attach_function :track_duration, :sp_track_duration, [ :track ], :int
  attach_function :track_popularity, :sp_track_popularity, [ :track ], :int
  attach_function :track_disc, :sp_track_disc, [ :track ], :int
  attach_function :track_index, :sp_track_index, [ :track ], :int
  attach_function :localtrack_create, :sp_localtrack_create, [ :string, :string, :string, :int ], :track

  attach_function :track_add_ref, :sp_track_add_ref, [ :track ], :void
  attach_function :track_release, :sp_track_release, [ :track ], :void

  #
  # Albums
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__album.html

  #
  enum :albumtype, [:album, :single, :compilation, :unknown]

  attach_function :album_is_loaded, :sp_album_is_loaded, [ :album ], :bool
  attach_function :album_is_available, :sp_album_is_available, [ :album ], :bool
  attach_function :album_artist, :sp_album_artist, [ :album ], :artist
  attach_function :album_cover, :sp_album_cover, [ :album ], :image_id
  attach_function :album_name, :sp_album_name, [ :album ], :string
  attach_function :album_year, :sp_album_year, [ :album ], :int
  attach_function :album_type, :sp_album_type, [ :album ], :albumtype

  attach_function :album_add_ref, :sp_album_add_ref, [ :album ], :void
  attach_function :album_release, :sp_album_release, [ :album ], :void

  #
  # Album Browser
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__albumbrowse.html

  #
  callback :albumbrowse_complete_cb, [:albumbrowse, :userdata], :void
  attach_function :albumbrowse_create, :sp_albumbrowse_create, [ :session, :album, :albumbrowse_complete_cb, :userdata ], :albumbrowse
  attach_function :albumbrowse_is_loaded, :sp_albumbrowse_is_loaded, [ :albumbrowse ], :bool
  attach_function :albumbrowse_error, :sp_albumbrowse_error, [ :albumbrowse ], :error
  attach_function :albumbrowse_album, :sp_albumbrowse_album, [ :albumbrowse ], :album
  attach_function :albumbrowse_artist, :sp_albumbrowse_artist, [ :albumbrowse ], :artist
  attach_function :albumbrowse_num_copyrights, :sp_albumbrowse_num_copyrights, [ :albumbrowse ], :int
  attach_function :albumbrowse_copyright, :sp_albumbrowse_copyright, [ :albumbrowse, :int ], :string
  attach_function :albumbrowse_num_tracks, :sp_albumbrowse_num_tracks, [ :albumbrowse ], :int
  attach_function :albumbrowse_track, :sp_albumbrowse_track, [ :albumbrowse, :int ], :track
  attach_function :albumbrowse_review, :sp_albumbrowse_review, [ :albumbrowse ], :string

  attach_function :albumbrowse_add_ref, :sp_albumbrowse_add_ref, [ :albumbrowse ], :void
  attach_function :albumbrowse_release, :sp_albumbrowse_release, [ :albumbrowse ], :void

  #
  # Artists
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__artist.html

  #
  attach_function :artist_name, :sp_artist_name, [ :artist ], :string
  attach_function :artist_is_loaded, :sp_artist_is_loaded, [ :artist ], :bool

  attach_function :artist_add_ref, :sp_artist_add_ref, [ :artist ], :void
  attach_function :artist_release, :sp_artist_release, [ :artist ], :void

  #
  # Artist Browsing
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__artistbrowse.html

  #
  callback :artistbrowse_complete_cb, [:artistbrowse, :userdata], :void
  attach_function :artistbrowse_create, :sp_artistbrowse_create, [ :session, :artist, :artistbrowse_complete_cb, :userdata ], :artistbrowse
  attach_function :artistbrowse_is_loaded, :sp_artistbrowse_is_loaded, [ :artistbrowse ], :bool
  attach_function :artistbrowse_error, :sp_artistbrowse_error, [ :artistbrowse ], :error
  attach_function :artistbrowse_artist, :sp_artistbrowse_artist, [ :artistbrowse ], :artist
  attach_function :artistbrowse_num_portraits, :sp_artistbrowse_num_portraits, [ :artistbrowse ], :int
  attach_function :artistbrowse_portrait, :sp_artistbrowse_portrait, [ :artistbrowse, :int ], :image_id
  attach_function :artistbrowse_num_tracks, :sp_artistbrowse_num_tracks, [ :artistbrowse ], :int
  attach_function :artistbrowse_track, :sp_artistbrowse_track, [ :artistbrowse, :int ], :track
  attach_function :artistbrowse_num_albums, :sp_artistbrowse_num_albums, [ :artistbrowse ], :int
  attach_function :artistbrowse_album, :sp_artistbrowse_album, [ :artistbrowse, :int ], :album
  attach_function :artistbrowse_num_similar_artists, :sp_artistbrowse_num_similar_artists, [ :artistbrowse ], :int
  attach_function :artistbrowse_similar_artist, :sp_artistbrowse_similar_artist, [ :artistbrowse, :int ], :artist
  attach_function :artistbrowse_biography, :sp_artistbrowse_biography, [ :artistbrowse ], :string

  attach_function :artistbrowse_add_ref, :sp_artistbrowse_add_ref, [ :artistbrowse ], :void
  attach_function :artistbrowse_release, :sp_artistbrowse_release, [ :artistbrowse ], :void

  #
  # Images
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__image.html

  #
  enum :imageformat, [:unknown, -1, :jpeg]

  callback :image_loaded_cb, [ :image, :userdata ], :void
  attach_function :image_create, :sp_image_create, [ :session, :image_id ], :image
  attach_function :image_add_load_callback, :sp_image_add_load_callback, [ :image, :image_loaded_cb, :userdata ], :void
  attach_function :image_remove_load_callback, :sp_image_remove_load_callback, [ :image, :image_loaded_cb, :userdata ], :void
  attach_function :image_is_loaded, :sp_image_is_loaded, [ :image ], :bool
  attach_function :image_error, :sp_image_error, [ :image ], :error
  attach_function :image_format, :sp_image_format, [ :image ], :imageformat
  attach_function :image_data, :sp_image_data, [ :image, :pointer ], :buffer_out
  attach_function :image_image_id, :sp_image_image_id, [ :image ], :image_id
  attach_function :image_create_from_link, :sp_image_create_from_link, [ :session, :link ], :image

  attach_function :image_add_ref, :sp_image_add_ref, [ :image ], :void
  attach_function :image_release, :sp_image_release, [ :image ], :void

  #
  # Searching
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__search.html

  #
  enum :radio_genre, [
    :alt_pop_rock, 0x1,
    :blues       , 0x2,
    :country     , 0x4,
    :disco       , 0x8,
    :funk        , 0x10,
    :hard_rock   , 0x20,
    :heavy_metal , 0x40,
    :rap         , 0x80,
    :house       , 0x100,
    :jazz        , 0x200,
    :new_wave    , 0x400,
    :rnb         , 0x800,
    :pop         , 0x1000,
    :punk        , 0x2000,
    :reggae      , 0x4000,
    :pop_rock    , 0x8000,
    :soul        , 0x10000,
    :techno      , 0x20000
  ]

  callback :search_complete_cb, [:search, :userdata], :void
  attach_function :search_create, :sp_search_create, [ :session, :string, :int, :int, :int, :int, :int, :int, :search_complete_cb, :userdata ], :search
  attach_function :radio_search_create, :sp_radio_search_create, [ :session, :uint, :uint, :radio_genre, :search_complete_cb, :userdata ], :search
  attach_function :search_is_loaded, :sp_search_is_loaded, [ :search ], :bool
  attach_function :search_error, :sp_search_error, [ :search ], :error
  attach_function :search_num_tracks, :sp_search_num_tracks, [ :search ], :int
  attach_function :search_track, :sp_search_track, [ :search, :int ], :track
  attach_function :search_num_albums, :sp_search_num_albums, [ :search ], :int
  attach_function :search_album, :sp_search_album, [ :search, :int ], :album
  attach_function :search_num_artists, :sp_search_num_artists, [ :search ], :int
  attach_function :search_artist, :sp_search_artist, [ :search, :int ], :artist
  attach_function :search_query, :sp_search_query, [ :search ], :string
  attach_function :search_did_you_mean, :sp_search_did_you_mean, [ :search ], :string
  attach_function :search_total_tracks, :sp_search_total_tracks, [ :search ], :int
  attach_function :search_total_albums, :sp_search_total_albums, [ :search ], :int
  attach_function :search_total_artists, :sp_search_total_artists, [ :search ], :int

  attach_function :search_add_ref, :sp_search_add_ref, [ :search ], :void
  attach_function :search_release, :sp_search_release, [ :search ], :void

  #
  # Playlists
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__playlist.html

  # FFI::Struct for Playlist callbacks.
  #
  # @attr [callback(:playlist, :array, :int, :int, :userdata):void] tracks_added
  # @attr [callback(:playlist, :array, :int, :userdata):void] tracks_removed
  # @attr [callback(:playlist, :array, :int, :int, :userdata):void] tracks_moved
  # @attr [callback(:playlist, :userdata):void] playlist_renamed
  # @attr [callback(:playlist, :userdata):void] playlist_state_changed
  # @attr [callback(:playlist, :bool, :userdata):void] playlist_update_in_progress
  # @attr [callback(:playlist, :userdata):void] playlist_metadata_updated
  # @attr [callback(:playlist, :int, :user, :int, :userdata):void] track_created_changed
  # @attr [callback(:playlist, :int, :bool, :userdata):void] track_seen_changed
  # @attr [callback(:playlist, :string, :userdata):void] description_changed
  # @attr [callback(:playlist, :image_id, :userdata):void] image_changed
  # @attr [callback(:playlist, :int, :string, :userdata):void] track_message_changed
  # @attr [callback(:playlist, :userdata):void] subscribers_changed
  class PlaylistCallbacks < FFI::Struct
    layout :tracks_added, callback([ :playlist, :array, :int, :int, :userdata ], :void),
           :tracks_removed, callback([ :playlist, :array, :int, :userdata ], :void),
           :tracks_moved, callback([ :playlist, :array, :int, :int, :userdata ], :void),
           :playlist_renamed, callback([ :playlist, :userdata ], :void),
           :playlist_state_changed, callback([ :playlist, :userdata ], :void),
           :playlist_update_in_progress, callback([ :playlist, :bool, :userdata ], :void),
           :playlist_metadata_updated, callback([ :playlist, :userdata ], :void),
           :track_created_changed, callback([ :playlist, :int, :user, :int, :userdata ], :void),
           :track_seen_changed, callback([ :playlist, :int, :bool, :userdata ], :void),
           :description_changed, callback([ :playlist, :string, :userdata ], :void),
           :image_changed, callback([ :playlist, :image_id, :userdata ], :void),
           :track_message_changed, callback([ :playlist, :int, :string, :userdata ], :void),
           :subscribers_changed, callback([ :playlist, :userdata ], :void)
  end

  # FFI::Struct for Subscribers of a Playlist.
  #
  # @attr [Fixnum] count
  # @attr [Pointer<String>] subscribers
  class Subscribers < FFI::Struct
    layout :count, :uint,
           :subscribers, :array # array of count strings
  end

  #
  enum :playlist_type, [:playlist, :start_folder, :end_folder, :placeholder]

  #
  enum :playlist_offline_status, [:no, :yes, :downloading, :waiting]

  attach_function :playlist_is_loaded, :sp_playlist_is_loaded, [ :playlist ], :bool
  attach_function :playlist_add_callbacks, :sp_playlist_add_callbacks, [ :playlist, PlaylistCallbacks, :userdata ], :void
  attach_function :playlist_remove_callbacks, :sp_playlist_remove_callbacks, [ :playlist, PlaylistCallbacks, :userdata ], :void
  attach_function :playlist_num_tracks, :sp_playlist_num_tracks, [ :playlist ], :int
  attach_function :playlist_track, :sp_playlist_track, [ :playlist, :int ], :track
  attach_function :playlist_track_create_time, :sp_playlist_track_create_time, [ :playlist, :int ], :int
  attach_function :playlist_track_creator, :sp_playlist_track_creator, [ :playlist, :int ], :user
  attach_function :playlist_track_seen, :sp_playlist_track_seen, [ :playlist, :int ], :bool
  attach_function :playlist_track_set_seen, :sp_playlist_track_set_seen, [ :playlist, :int, :bool ], :error
  attach_function :playlist_track_message, :sp_playlist_track_message, [ :playlist, :int ], :string
  attach_function :playlist_name, :sp_playlist_name, [ :playlist ], :string
  attach_function :playlist_rename, :sp_playlist_rename, [ :playlist, :string ], :error
  attach_function :playlist_owner, :sp_playlist_owner, [ :playlist ], :user
  attach_function :playlist_is_collaborative, :sp_playlist_is_collaborative, [ :playlist ], :bool
  attach_function :playlist_set_collaborative, :sp_playlist_set_collaborative, [ :playlist, :bool ], :void
  attach_function :playlist_set_autolink_tracks, :sp_playlist_set_autolink_tracks, [ :playlist, :bool ], :void
  attach_function :playlist_get_description, :sp_playlist_get_description, [ :playlist ], :string
  attach_function :playlist_get_image, :sp_playlist_get_image, [ :playlist, :image_id ], :bool
  attach_function :playlist_has_pending_changes, :sp_playlist_has_pending_changes, [ :playlist ], :bool
  attach_function :playlist_add_tracks, :sp_playlist_add_tracks, [ :playlist, :array, :int, :int, :session ], :error
  attach_function :playlist_remove_tracks, :sp_playlist_remove_tracks, [ :playlist, :array, :int ], :error
  attach_function :playlist_reorder_tracks, :sp_playlist_reorder_tracks, [ :playlist, :array, :int, :int ], :error
  attach_function :playlist_num_subscribers, :sp_playlist_num_subscribers, [ :playlist ], :uint
  attach_function :playlist_subscribers, :sp_playlist_subscribers, [ :playlist ], Subscribers
  attach_function :playlist_subscribers_free, :sp_playlist_subscribers_free, [ Subscribers ], :void
  attach_function :playlist_update_subscribers, :sp_playlist_update_subscribers, [ :session, :playlist ], :void
  attach_function :playlist_is_in_ram, :sp_playlist_is_in_ram, [ :session, :playlist ], :bool
  attach_function :playlist_set_in_ram, :sp_playlist_set_in_ram, [ :session, :playlist, :bool ], :void
  attach_function :playlist_create, :sp_playlist_create, [ :session, :link ], :playlist
  attach_function :playlist_get_offline_status, :sp_playlist_get_offline_status, [ :session, :playlist ], :playlist_offline_status
  attach_function :playlist_get_offline_download_completed, :sp_playlist_get_offline_download_completed, [ :session, :playlist ], :int
  attach_function :playlist_set_offline_mode, :sp_playlist_set_offline_mode, [ :session, :playlist, :bool ], :void

  attach_function :playlist_add_ref, :sp_playlist_add_ref, [ :playlist ], :void
  attach_function :playlist_release, :sp_playlist_release, [ :playlist ], :void

  #
  # Playlist Container
  #

  # FFI::Struct for the PlaylistContainer.
  #
  # @attr [callback(:playlistcontainer, :playlist, :int, :userdata):void] playlist_added
  # @attr [callback(:playlistcontainer, :playlist, :int, :userdata):void] playlist_removed
  # @attr [callback(:playlistcontainer, :playlist, :int, :int, :userdata):void] playlist_moved
  # @attr [callback(:playlistcontainer, :userdata):void] container_loaded
  class PlaylistContainerCallbacks < FFI::Struct
    layout :playlist_added, callback([ :playlistcontainer, :playlist, :int, :userdata ], :void),
           :playlist_removed, callback([ :playlistcontainer, :playlist, :int, :userdata ], :void),
           :playlist_moved, callback([ :playlistcontainer, :playlist, :int, :int, :userdata ], :void),
           :container_loaded, callback([ :playlistcontainer, :userdata ], :void)
  end

  #
  attach_function :playlistcontainer_add_callbacks, :sp_playlistcontainer_add_callbacks, [ :playlistcontainer, PlaylistContainerCallbacks, :userdata ], :void
  attach_function :playlistcontainer_remove_callbacks, :sp_playlistcontainer_remove_callbacks, [ :playlistcontainer, PlaylistContainerCallbacks, :userdata ], :void
  attach_function :playlistcontainer_num_playlists, :sp_playlistcontainer_num_playlists, [ :playlistcontainer ], :int
  attach_function :playlistcontainer_playlist, :sp_playlistcontainer_playlist, [ :playlistcontainer, :int ], :playlist
  attach_function :playlistcontainer_playlist_type, :sp_playlistcontainer_playlist_type, [ :playlistcontainer, :int ], :playlist_type
  attach_function :playlistcontainer_playlist_folder_name, :sp_playlistcontainer_playlist_folder_name, [ :playlistcontainer, :int, :buffer_out, :int ], :error
  attach_function :playlistcontainer_playlist_folder_id, :sp_playlistcontainer_playlist_folder_id, [ :playlistcontainer, :int ], :uint64
  attach_function :playlistcontainer_add_new_playlist, :sp_playlistcontainer_add_new_playlist, [ :playlistcontainer, :string ], :playlist
  attach_function :playlistcontainer_add_playlist, :sp_playlistcontainer_add_playlist, [ :playlistcontainer, :link ], :playlist
  attach_function :playlistcontainer_remove_playlist, :sp_playlistcontainer_remove_playlist, [ :playlistcontainer, :int ], :error
  attach_function :playlistcontainer_move_playlist, :sp_playlistcontainer_move_playlist, [ :playlistcontainer, :int, :int, :bool ], :error
  attach_function :playlistcontainer_add_folder, :sp_playlistcontainer_add_folder, [ :playlistcontainer, :int, :string ], :error
  attach_function :playlistcontainer_owner, :sp_playlistcontainer_owner, [ :playlistcontainer ], :user
  attach_function :playlistcontainer_is_loaded, :sp_playlistcontainer_is_loaded, [ :playlistcontainer ], :bool

  attach_function :playlistcontainer_add_ref, :sp_playlistcontainer_add_ref, [ :playlistcontainer ], :void
  attach_function :playlistcontainer_release, :sp_playlistcontainer_release, [ :playlistcontainer ], :void

  #
  # User handling
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__user.html

  #
  enum :relation_type, [:unknown, :none, :unidirectional, :bidirectional]

  attach_function :user_canonical_name, :sp_user_canonical_name, [ :user ], :string
  attach_function :user_display_name, :sp_user_display_name, [ :user ], :string
  attach_function :user_is_loaded, :sp_user_is_loaded, [ :user ], :bool
  attach_function :user_full_name, :sp_user_full_name, [ :user ], :string
  attach_function :user_picture, :sp_user_picture, [ :user ], :string
  attach_function :user_relation_type, :sp_user_relation_type, [ :session, :user ], :relation_type

  attach_function :user_add_ref, :sp_user_add_ref, [ :user ], :void
  attach_function :user_release, :sp_user_release, [ :user ], :void

  #
  # Toplists
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__toplist.html

  #
  enum :toplisttype, [:artists, :albums, :tracks]
  enum :toplistregion, [:everywhere, :user]

  callback :toplistbrowse_complete_cb, [:toplistbrowse, :userdata], :void
  attach_function :toplistbrowse_create, :sp_toplistbrowse_create, [ :session, :toplisttype, :toplistregion, :string, :toplistbrowse_complete_cb, :userdata ], :toplistbrowse
  attach_function :toplistbrowse_is_loaded, :sp_toplistbrowse_is_loaded, [ :toplistbrowse ], :bool
  attach_function :toplistbrowse_error, :sp_toplistbrowse_error, [ :toplistbrowse ], :error
  attach_function :toplistbrowse_num_artists, :sp_toplistbrowse_num_artists, [ :toplistbrowse ], :int
  attach_function :toplistbrowse_artist, :sp_toplistbrowse_artist, [ :toplistbrowse, :int ], :artist
  attach_function :toplistbrowse_num_albums, :sp_toplistbrowse_num_albums, [ :toplistbrowse ], :int
  attach_function :toplistbrowse_album, :sp_toplistbrowse_album, [ :toplistbrowse, :int ], :album
  attach_function :toplistbrowse_num_tracks, :sp_toplistbrowse_num_tracks, [ :toplistbrowse ], :int
  attach_function :toplistbrowse_track, :sp_toplistbrowse_track, [ :toplistbrowse, :int ], :track

  attach_function :toplistbrowse_add_ref, :sp_toplistbrowse_add_ref, [ :toplistbrowse ], :void
  attach_function :toplistbrowse_release, :sp_toplistbrowse_release, [ :toplistbrowse ], :void

  #
  # Inbox
  #
  # @see http://developer.spotify.com/en/libspotify/docs/group__inbox.html

  #
  callback :inboxpost_complete_cb, [:inbox, :userdata], :void
  attach_function :inbox_post_tracks, :sp_inbox_post_tracks, [ :session, :string, :array, :int, :string, :inboxpost_complete_cb, :userdata ], :inbox
  attach_function :inbox_error, :sp_inbox_error, [ :inbox ], :error

  attach_function :inbox_add_ref, :sp_inbox_add_ref, [ :inbox ], :void
  attach_function :inbox_release, :sp_inbox_release, [ :inbox ], :void
end
