# This file contains a tiny (!) DSL that wraps existing Spotify
# functions into versions that return Spotify::Pointers instead
# of the usual FFI::Pointers. The Spotify::Pointer automatically
# manages the underlying pointers reference count, which allows
# us to piggyback on the Ruby GC mechanism.

module Spotify
  # Wraps the function `function` so that it always returns
  # a Spotify::Pointer with correct refcount. Functions that
  # contain the word `create` are assumed to start out with
  # a refcount of `+1`.
  #
  # @param [#to_s] function
  # @param [#to_s] return_type
  # @raise [NoMethodError] if `function` is not defined
  # @see Spotify::Pointer
  def self.wrap_function(function, return_type)
    original = method(function) # make sure it exists
    define_singleton_method("#{function}!") do |*args, &block|
      pointer = public_send(function, *args, &block)
      Spotify::Pointer.new(pointer, return_type, function !~ /create/)
    end
  end

  # @macro [attach] wrap_function
  #   Same as {Spotify}.`$1`, but wraps result in a {Spotify::Pointer}.
  #
  #   @method $1!
  #   @return [Spotify::Pointer<$2>]
  #   @see #$1
  wrap_function :session_user, :user
  wrap_function :session_playlistcontainer, :playlistcontainer
  wrap_function :session_inbox_create, :playlist
  wrap_function :session_starred_create, :playlist
  wrap_function :session_starred_for_user_create, :playlist
  wrap_function :session_publishedcontainer_for_user_create, :playlistcontainer

  wrap_function :track_artist, :artist
  wrap_function :track_album, :album
  wrap_function :localtrack_create, :track
  wrap_function :track_get_playable, :track

  wrap_function :album_artist, :artist

  wrap_function :albumbrowse_create, :albumbrowse
  wrap_function :albumbrowse_album, :album
  wrap_function :albumbrowse_artist, :artist
  wrap_function :albumbrowse_track, :track

  wrap_function :artistbrowse_create, :artistbrowse
  wrap_function :artistbrowse_artist, :artist
  wrap_function :artistbrowse_track, :track
  wrap_function :artistbrowse_album, :album
  wrap_function :artistbrowse_similar_artist, :artist
  wrap_function :artistbrowse_tophit_track, :track

  wrap_function :image_create, :image
  wrap_function :image_create_from_link, :image

  wrap_function :link_as_track, :track
  wrap_function :link_as_track_and_offset, :track
  wrap_function :link_as_album, :album
  wrap_function :link_as_artist, :artist
  wrap_function :link_as_user, :user

  wrap_function :link_create_from_string, :link
  wrap_function :link_create_from_track, :link
  wrap_function :link_create_from_album, :link
  wrap_function :link_create_from_artist, :link
  wrap_function :link_create_from_search, :link
  wrap_function :link_create_from_playlist, :link
  wrap_function :link_create_from_artist_portrait, :link
  wrap_function :link_create_from_artistbrowse_portrait, :link
  wrap_function :link_create_from_album_cover, :link
  wrap_function :link_create_from_image, :link
  wrap_function :link_create_from_user, :link

  wrap_function :search_create, :search
  wrap_function :search_track, :track
  wrap_function :search_album, :album
  wrap_function :search_artist, :artist

  wrap_function :playlist_track, :track
  wrap_function :playlist_track_creator, :user
  wrap_function :playlist_owner, :user
  wrap_function :playlist_create, :playlist

  wrap_function :playlistcontainer_playlist, :playlist
  wrap_function :playlistcontainer_add_new_playlist, :playlist
  wrap_function :playlistcontainer_add_playlist, :playlist
  wrap_function :playlistcontainer_owner, :user

  wrap_function :toplistbrowse_create, :toplistbrowse
  wrap_function :toplistbrowse_artist, :artist
  wrap_function :toplistbrowse_album, :album
  wrap_function :toplistbrowse_track, :track

  wrap_function :inbox_post_tracks, :inbox
end
