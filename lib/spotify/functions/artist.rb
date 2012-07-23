module Spotify
  # !@group Artist
  attach_function :artist_name, [ Artist ], UTF8String
  attach_function :artist_is_loaded, [ Artist ], :bool
  attach_function :artist_portrait, [ Artist, :image_size ], ImageID
  attach_function :artist_add_ref, [ Artist ], :error
  attach_function :artist_release, [ Artist ], :error
end
