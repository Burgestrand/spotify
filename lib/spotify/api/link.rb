module Spotify
  class API
    # @!group Link

    # Create a Link from a Spotify URI or Spotify HTTP URL.
    #
    # @param [String] spotify_uri can be regular spotify URI, or spotify HTTP URL
    # @return [Link]
    attach_function :link_create_from_string, [ BestEffortString ], Link

    # @param [Track] track
    # @param [Integer] offset number of milliseconds into track to link to
    # @return [Link, nil]
    attach_function :link_create_from_track, [ Track, :int ], Link

    # @param [Album] album
    # @return [Link, nil]
    attach_function :link_create_from_album, [ Album ], Link

    # @param [Artist] artist
    # @return [Link, nil]
    attach_function :link_create_from_artist, [ Artist ], Link

    # @param [Search] search
    # @return [Link, nil]
    attach_function :link_create_from_search, [ Search ], Link

    # @param [Playlist] playlist
    # @return [Link, nil]
    attach_function :link_create_from_playlist, [ Playlist ], Link

    # @param [Artist] artist
    # @param [Symbol] image_size one of :normal, :small, :large
    # @return [Link, nil]
    attach_function :link_create_from_artist_portrait, [ Artist, :image_size ], Link

    # @see #artistbrowse_num_portraits
    # @param [ArtistBrowse] artist_browse
    # @param [Integer] index number within 0...{#artistbrowse_num_portraits}
    # @return [Link, nil]
    attach_function :link_create_from_artistbrowse_portrait, [ ArtistBrowse, :int ], Link

    # @param [Album] album
    # @param [Symbol] image_size one of :normal, :small, :large
    # @return [Link, nil]
    attach_function :link_create_from_album_cover, [ Album, :image_size ], Link

    # @example image id from spotify URI
    #   image_id = ":\xD94#\xAD\xD9\x97f\xE0-V6\x05\xC6\xE7n\xD2\xB0\xE4P"
    #   image_uri = "spotify:image:3ad93423add99766e02d563605c6e76ed2b0e450"
    #   image = Spotify.image_create(session, image_id)
    #   image_link = Spotify.link_create_from_image(image)
    #
    #   # And here are some cool equivalents:
    #   image_id == ["3ad93423add99766e02d563605c6e76ed2b0e450"].pack("H40")
    #   image_uri == "spotify:image:#{image_id.unpack("H40")[0]}"
    #   image_link == Spotify.link_create_from_string(image_uri)
    #   image == Spotify.image_create_from_link(session, image_link)
    #
    # @param [Image] image
    # @return [Link]
    attach_function :link_create_from_image, [ Image ], Link

    # @param [User] user
    # @return [Link]
    attach_function :link_create_from_user, [ User ], Link

    # @example figuring out image link size
    #   Spotify.link_as_string(link, nil, 0) # => 44
    #
    # @example retrieving full link as string
    #   link_length = Spotify.link_as_string(link, nil, 0)
    #   link_uri = FFI::Buffer.alloc_out(link_length) do |ptr|
    #     Spotify.link_as_string(link, ptr, link_length)
    #     break ptr.read_string
    #   end
    #
    # @param [Link] link
    # @param [FFI::Pointer] image_uri_pointer pointer of where to store link as string
    # @param [Integer] image_uri_length size of image_uri_pointer
    # @return [Integer] total size of link uri length
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
end
