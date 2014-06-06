module Spotify
  class API
    # @!group Link

    # Create a Link from a Spotify URI or Spotify HTTP URL.
    #
    # @param [String] spotify_uri can be regular spotify URI, or spotify HTTP URL
    # @return [Link]
    # @method link_create_from_string(spotify_uri)
    attach_function :link_create_from_string, [ BestEffortString ], Link

    # @param [Track] track
    # @param [Integer] offset number of milliseconds into track to link to
    # @return [Link, nil]
    # @method link_create_from_track(track, offset)
    attach_function :link_create_from_track, [ Track, :int ], Link

    # @param [Album] album
    # @return [Link, nil]
    # @method link_create_from_album(album)
    attach_function :link_create_from_album, [ Album ], Link

    # @param [Artist] artist
    # @return [Link, nil]
    # @method link_create_from_artist(artist)
    attach_function :link_create_from_artist, [ Artist ], Link

    # @param [Search] search
    # @return [Link, nil]
    # @method link_create_from_search(search)
    attach_function :link_create_from_search, [ Search ], Link

    # @param [Playlist] playlist
    # @return [Link, nil]
    # @method link_create_from_playlist(playlist)
    attach_function :link_create_from_playlist, [ Playlist ], Link

    # @param [Artist] artist
    # @param [Symbol] image_size one of :normal, :small, :large
    # @return [Link, nil]
    # @method link_create_from_artist_portrait(artist, image_size)
    attach_function :link_create_from_artist_portrait, [ Artist, :image_size ], Link

    # @see #artistbrowse_num_portraits
    # @param [ArtistBrowse] artist_browse
    # @param [Integer] index number within 0...{#artistbrowse_num_portraits}
    # @return [Link, nil]
    # @method link_create_from_artistbrowse_portrait(artist_browse, index)
    attach_function :link_create_from_artistbrowse_portrait, [ ArtistBrowse, :int ], Link

    # @param [Album] album
    # @param [Symbol] image_size one of :normal, :small, :large
    # @return [Link, nil]
    # @method link_create_from_album_cover(album, image_size)
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
    # @method link_create_from_image(image)
    attach_function :link_create_from_image, [ Image ], Link

    # @param [User] user
    # @return [Link]
    # @method link_create_from_user(user)
    attach_function :link_create_from_user, [ User ], Link

    # Retrieve string representation of link.
    #
    # @example
    #   Spotify.link_as_string(link) # => "spotify:user:burgestrand"
    #
    # @param [Link] link
    # @return [String] string representation of the link
    # @method link_as_string(link)
    attach_function :link_as_string, [ Link, :buffer_out, :int ], :int do |link|
      link_length = sp_link_as_string(link, nil, 0)
      FFI::Buffer.alloc_out(:char, link_length + 1) do |string_pointer|
        sp_link_as_string(link, string_pointer, string_pointer.size)
        return string_pointer.get_string(0, link_length).force_encoding("UTF-8")
      end
    end

    # @param [Link] link
    # @return [Symbol] type of link, one of :invalid, :track, :album, :artist, :search, :playlist, :profile, :starred, :localtrack, :image
    # @method link_type(link)
    attach_function :link_type, [ Link ], :linktype

    # @param [Link] link
    # @return [Track, nil] track pointed to by the link, or nil if not a track
    # @method link_as_track(link)
    attach_function :link_as_track, [ Link ], Track

    # @example
    #   track, offset = FFI::MemoryPointer.new(:int) do |offset_pointer|
    #     track = Spotify.link_as_track_and_offset(link, offset_pointer)
    #     break [track, offset_pointer.read_int]
    #   end
    #
    # @note if no track offset is available in the link, the offset out will always be set to 0.
    # @param [Link] link
    # @param [FFI::Pointer] offset_out offset into track the link is pointing to, in milliseconds
    # @return [Track, nil] track pointed to by the link, along with offset information
    # @method link_as_track_and_offset(link, offset_out)
    attach_function :link_as_track_and_offset, [ Link, :buffer_out ], Track

    # @param [Link] link
    # @return [Album, nil] album pointed to by the link, or nil if not an album
    # @method link_as_album(link)
    attach_function :link_as_album, [ Link ], Album

    # @param [Link] link
    # @return [Artist, nil] artist pointed to by the link, or nil if not an artist
    # @method link_as_artist(link)
    attach_function :link_as_artist, [ Link ], Artist

    # @param [Link] link
    # @return [User, nil] user pointed to by the link, or nil if not a user
    # @method link_as_user(link)
    attach_function :link_as_user, [ Link ], User

    attach_function :link_add_ref, [ Link ], :error
    attach_function :link_release, [ Link ], :error
  end
end
