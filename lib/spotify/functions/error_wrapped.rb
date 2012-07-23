module Spotify
  # @!macro [attach] wrap_function
  #   @!method $1!
  #     Same as {$1}, but raises a Spotify::Error on error.
  #
  #     @!scope class
  #     @see $1
  #     @raise [Spotify::Error] if libspotify returns an error
  #     @return (error)
  #
  # Wraps the function `function` so that it raises an error if
  # the return error is not :ok.
  #
  # @note This method is removed at the bottom of this file.
  #
  # @param [#to_s] function
  # @raise [NoMethodError] if `function` is not defined
  def self.wrap_function(function)
    unless respond_to?(function)
      raise NoMethodError, "#{function} does not exist!"
    end

    define_singleton_method("#{function}!") do |*args, &block|
      error = public_send(function, *args, &block)
      raise Error.new(error) unless error == :ok
    end
  end

  # @!group Error-raising
  wrap_function :session_create
  wrap_function :session_release
  wrap_function :session_process_events
  wrap_function :session_login
  wrap_function :session_relogin
  wrap_function :session_forget_me
  wrap_function :session_logout
  wrap_function :session_set_cache_size
  wrap_function :session_player_load
  wrap_function :session_player_seek
  wrap_function :session_player_play
  wrap_function :session_player_unload
  wrap_function :session_player_prefetch
  wrap_function :session_preferred_bitrate
  wrap_function :session_set_connection_type
  wrap_function :session_set_connection_rules
  wrap_function :session_preferred_offline_bitrate
  wrap_function :session_set_volume_normalization
  wrap_function :session_flush_caches
  wrap_function :session_set_private_session
  wrap_function :session_set_scrobbling
  wrap_function :session_is_scrobbling
  wrap_function :session_is_scrobbling_possible
  wrap_function :session_set_social_credentials

  wrap_function :image_add_load_callback
  wrap_function :image_remove_load_callback
  wrap_function :image_error
  wrap_function :image_add_ref
  wrap_function :image_release

  wrap_function :link_add_ref
  wrap_function :link_release

  wrap_function :track_error
  wrap_function :track_set_starred
  wrap_function :track_add_ref
  wrap_function :track_release

  wrap_function :album_add_ref
  wrap_function :album_release

  wrap_function :albumbrowse_error
  wrap_function :albumbrowse_add_ref
  wrap_function :albumbrowse_release

  wrap_function :artist_add_ref
  wrap_function :artist_release

  wrap_function :artistbrowse_error
  wrap_function :artistbrowse_add_ref
  wrap_function :artistbrowse_release

  wrap_function :search_error
  wrap_function :search_add_ref
  wrap_function :search_release

  wrap_function :playlist_add_callbacks
  wrap_function :playlist_remove_callbacks
  wrap_function :playlist_track_set_seen
  wrap_function :playlist_rename
  wrap_function :playlist_set_collaborative
  wrap_function :playlist_set_autolink_tracks
  wrap_function :playlist_add_tracks
  wrap_function :playlist_remove_tracks
  wrap_function :playlist_reorder_tracks
  wrap_function :playlist_subscribers_free
  wrap_function :playlist_update_subscribers
  wrap_function :playlist_set_in_ram
  wrap_function :playlist_set_offline_mode
  wrap_function :playlist_add_ref
  wrap_function :playlist_release

  wrap_function :playlistcontainer_add_callbacks
  wrap_function :playlistcontainer_remove_callbacks
  wrap_function :playlistcontainer_playlist_folder_name
  wrap_function :playlistcontainer_remove_playlist
  wrap_function :playlistcontainer_move_playlist
  wrap_function :playlistcontainer_add_folder
  wrap_function :playlistcontainer_add_ref
  wrap_function :playlistcontainer_release

  wrap_function :user_add_ref
  wrap_function :user_release

  wrap_function :toplistbrowse_error
  wrap_function :toplistbrowse_add_ref
  wrap_function :toplistbrowse_release

  wrap_function :inbox_error
  wrap_function :inbox_add_ref
  wrap_function :inbox_release

  # Clean up
  class << self; undef :wrap_function; end
end
