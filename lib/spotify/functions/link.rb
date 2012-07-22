module Spotify
  attach_function :link_create_from_string, [ :string ], Link
  attach_function :link_create_from_track, [ Track, :int ], Link
  attach_function :link_create_from_album, [ Album ], Link
  attach_function :link_create_from_artist, [ Artist ], Link
  attach_function :link_create_from_search, [ Search ], Link
  attach_function :link_create_from_playlist, [ Playlist ], Link
  attach_function :link_create_from_artist_portrait, [ Artist, :image_size ], Link
  attach_function :link_create_from_artistbrowse_portrait, [ ArtistBrowse, :int ], Link
  attach_function :link_create_from_album_cover, [ Album, :image_size ], Link
  attach_function :link_create_from_image, [ Image ], Link
  attach_function :link_create_from_user, [ User ], Link
  attach_function :link_as_string, [ Link, :buffer_out, :int ], :int
  attach_function :link_type, [ Link ], :linktype
  attach_function :link_as_track, [ Link ], Track
  attach_function :link_as_track_and_offset, [ Link, :buffer_out ], Track
  attach_function :link_as_album, [ Link ], Album
  attach_function :link_as_artist, [ Link ], Artist
  attach_function :link_as_user, [ Link ], User
  attach_function :link_add_ref, [ Link ], :error
  attach_function :link_release, [ Link ], :error
end
