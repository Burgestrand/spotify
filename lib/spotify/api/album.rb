class SpotifyAPI
  # @!group Album
  attach_function :album_is_loaded, [ Album ], :bool
  attach_function :album_is_available, [ Album ], :bool
  attach_function :album_artist, [ Album ], Artist
  attach_function :album_cover, [ Album, :image_size ], ImageID
  attach_function :album_name, [ Album ], UTF8String
  attach_function :album_year, [ Album ], :int
  attach_function :album_type, [ Album ], :albumtype
  attach_function :album_add_ref, [ Album ], :error
  attach_function :album_release, [ Album ], :error
end
