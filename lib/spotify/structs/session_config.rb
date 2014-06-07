module Spotify
  # Spotify::Struct for Session configuration.
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
  class SessionConfig < Spotify::Struct
    it = {}
    it[:api_version] = :int
    it[:cache_location] = UTF8StringPointer
    it[:settings_location] = UTF8StringPointer
    it[:application_key] = ByteString
    it[:application_key_size] = :size_t
    it[:user_agent] = UTF8StringPointer
    it[:callbacks] = SessionCallbacks.by_ref
    it[:userdata] = :userdata
    it[:compress_playlists] = :bool
    it[:dont_save_metadata_for_playlists] = :bool
    it[:initially_unload_playlists] = :bool
    it[:device_id] = UTF8StringPointer
    it[:proxy] = UTF8StringPointer
    it[:proxy_username] = UTF8StringPointer
    it[:proxy_password] = UTF8StringPointer
    it[:ca_certs_filename] = UTF8StringPointer if Spotify::Util.linux?
    it[:tracefile] = UTF8StringPointer
    layout(it)

    # Overridden for some keys for convenience.
    #
    # @example setting application key
    #   struct[:application_key] = "application key"
    #   # ^ also sets :application_key_size
    #
    # @param [Symbol] key
    # @param [Object] value
    def []=(key, value)
      case key
      when :application_key
        super(key, value)
        self[:application_key_size] = value.bytesize if value
      else super
      end
    end
  end
end
