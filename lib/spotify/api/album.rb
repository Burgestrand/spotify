module Spotify
  class API
    # @!group Album

    # @param [Album] album
    # @return [Boolean] true if the album is populated with data
    # @method album_is_loaded(album)
    attach_function :album_is_loaded, [ Album ], :bool

    # @see #album_is_loaded
    # @note the album must be loaded, or this function always return false.
    # @param [Album] album
    # @return [Boolean] true if the album is available for playback
    # @method album_is_available(album)
    attach_function :album_is_available, [ Album ], :bool

    # @see #album_is_loaded
    # @note the album must be loaded, or this function always return nil.
    # @param [Album] album
    # @return [Artist, nil] authoring artist of the album
    # @method album_artist(album)
    attach_function :album_artist, [ Album ], Artist

    # @see #image_create
    # @see #album_is_loaded
    # @note the album must be loaded, or this function always return nil.
    # @param [Album] album
    # @param [Symbol] image_size one of :normal, :small, :large
    # @return [String, nil] image ID to pass to {#image_create}, or nil if the album has no image
    # @method album_cover(album, image_size)
    attach_function :album_cover, [ Album, :image_size ], ImageID

    # @see #album_is_loaded
    # @note the album must be loaded, or this function always return an empty string.
    # @param [Album] album
    # @return [String] name of the album
    # @method album_name(album)
    attach_function :album_name, [ Album ], UTF8String

    # @see #album_is_loaded
    # @note the album must be loaded, or this function always return 0.
    # @param [Album] album
    # @return [String] release year of the album
    # @method album_year(album)
    attach_function :album_year, [ Album ], :int

    # @see #album_is_loaded
    # @note the album must be loaded, or this function always return :unknown.
    # @param [Album] album
    # @return [Symbol] album type, one of :album, :single, :compilation, :unknown
    # @method album_type(album)
    attach_function :album_type, [ Album ], :albumtype

    attach_function :album_add_ref, [ Album ], :error
    attach_function :album_release, [ Album ], :error
  end
end
