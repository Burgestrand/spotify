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
    it[:cache_location] = NULString
    it[:settings_location] = NULString
    it[:application_key] = :pointer
    it[:application_key_size] = :size_t
    it[:user_agent] = NULString
    it[:callbacks] = SessionCallbacks.by_ref
    it[:userdata] = :userdata
    it[:compress_playlists] = :bool
    it[:dont_save_metadata_for_playlists] = :bool
    it[:initially_unload_playlists] = :bool
    it[:device_id] = NULString
    it[:proxy] = NULString
    it[:proxy_username] = NULString
    it[:proxy_password] = NULString
    it[:ca_certs_filename] = NULString if Spotify::API.linux?
    it[:tracefile] = NULString
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
        if value.is_a?(String)
          pointer = FFI::MemoryPointer.new(:char, value.bytesize)
          pointer.write_string(value)
          super(key, pointer)
          self[:application_key_size] = pointer.size
        else
          super
        end
      else super
      end
    end
  end
end
