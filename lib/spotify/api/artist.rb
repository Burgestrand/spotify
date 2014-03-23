module Spotify
  class API
    # @!group Artist

    # @see #artist_is_loaded
    # @note the artist must be loaded, or this function always return an empty string.
    # @param [Artist] artist
    # @return [String] name of the artist
    attach_function :artist_name, [ Artist ], UTF8String

    # @param [Artist] artist
    # @return [Boolean] true if the artist is populated with data
    attach_function :artist_is_loaded, [ Artist ], :bool

    # @see #image_create
    # @see #artist_is_loaded
    # @note the artist must be loaded, or this function always return nil.
    # @param [Artist] artist
    # @param [Symbol] image_size one of :normal, :small, :large
    # @return [String, nil] image ID to pass to {#image_create}, or nil if the artist has no image
    attach_function :artist_portrait, [ Artist, :image_size ], ImageID

    attach_function :artist_add_ref, [ Artist ], :error
    attach_function :artist_release, [ Artist ], :error
  end
end
