require 'spotify/managed_pointer'

require 'spotify/types/album'
require 'spotify/types/album_browse'
require 'spotify/types/artist'
require 'spotify/types/artist_browse'
require 'spotify/types/image'
require 'spotify/types/inbox'
require 'spotify/types/link'
require 'spotify/types/playlist'
require 'spotify/types/playlist_container'
require 'spotify/types/search'
require 'spotify/types/session'
require 'spotify/types/toplist_browse'
require 'spotify/types/track'
require 'spotify/types/user'

module Spotify
  class API
    typedef :pointer, :frames
    typedef :pointer, :userdata
    typedef :pointer, :array

    #
    # Error
    #
    enum :error, [:ok, 0,
                  :bad_api_version, :api_initialization_failed, :track_not_playable,

                  :bad_application_key, 5,
                  :bad_username_or_password, :user_banned,
                  :unable_to_contact_server, :client_too_old, :other_permanent,
                  :bad_user_agent, :missing_callback, :invalid_indata,
                  :index_out_of_range, :user_needs_premium, :other_transient,
                  :is_loading, :no_stream_available, :permission_denied,
                  :inbox_is_full, :no_cache, :no_such_user, :no_credentials,
                  :network_disabled, :invalid_device_id, :cant_open_trace_file,
                  :application_banned,

                  :offline_too_many_tracks, 31,
                  :offline_disk_cache, :offline_expired, :offline_not_allowed,
                  :offline_license_lost, :offline_license_error,

                  :lastfm_auth_error, 39,
                  :invalid_argument, :system_failure]

    #
    # Audio
    #
    enum :sampletype, [:int16] # int16_native_endian
    enum :bitrate, %w(160k 320k 96k).map(&:to_sym)

    #
    # Session
    #
    enum :social_provider, [:spotify, :facebook, :lastfm]
    enum :scrobbling_state, [:use_global_setting, :local_enabled, :local_disabled, :global_enabled, :global_disabled]
    enum :connectionstate, [:logged_out, :logged_in, :disconnected, :undefined, :offline]
    enum :connection_type, [:unknown, :none, :mobile, :mobile_roaming, :wifi, :wired]
    enum :connection_rules, [:network               , 0x1,
                             :network_if_roaming    , 0x2,
                             :allow_sync_over_mobile, 0x4,
                             :allow_sync_over_wifi  , 0x8]

    #
    # Image
    #
    callback :image_loaded_cb, [ Image.retaining_class, :userdata ], :void
    enum :imageformat, [:unknown, -1, :jpeg]
    enum :image_size, [ :normal, :small, :large ]

    #
    # Link
    #
    enum :linktype, [:invalid, :track, :album, :artist, :search,
                     :playlist, :profile, :starred, :localtrack, :image]

    #
    # Track
    #
    enum :availability, [:unavailable, :available, :not_streamable, :banned_by_artist]
    typedef :availability, :track_availability # for automated testing
    enum :track_offline_status, [:no, :waiting, :downloading, :done, :error, :done_expired, :limit_exceeded, :done_resync]

    #
    # Album
    #
    callback :albumbrowse_complete_cb, [AlbumBrowse.retaining_class, :userdata], :void
    enum :albumtype, [:album, :single, :compilation, :unknown]

    #
    # Artist browsing
    #
    callback :artistbrowse_complete_cb, [ArtistBrowse.retaining_class, :userdata], :void
    enum :artistbrowse_type, [:full, :no_tracks, :no_albums]

    #
    # Search
    #
    callback :search_complete_cb, [Search.retaining_class, :userdata], :void
    enum :search_type, [:standard, :suggest]

    #
    # Playlist
    #
    enum :playlist_type, [:playlist, :start_folder, :end_folder, :placeholder]
    enum :playlist_offline_status, [:no, :yes, :downloading, :waiting]

    #
    # User
    #
    enum :relation_type, [:unknown, :none, :unidirectional, :bidirectional]

    #
    # Toplist
    #
    callback :toplistbrowse_complete_cb, [ToplistBrowse.retaining_class, :userdata], :void
    enum :toplisttype, [:artists, :albums, :tracks]
    enum :toplistregion, [:everywhere, :user]

    #
    # Inbox
    #
    callback :inboxpost_complete_cb, [Inbox.retaining_class, :userdata], :void
  end
end
