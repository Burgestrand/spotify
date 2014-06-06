module Spotify
  class API
    # @!group Image

    # @param [Session] session
    # @param [String] image_id
    # @return [Image] image from an image id
    # @method image_create(session, image_id)
    attach_function :image_create, [ Session, ImageID ], Image

    # Add a callback that will be invoked when the image is loaded.
    #
    # @note make *very* sure the callback proc is not garbage collected before it is called!
    # @see #image_remove_load_callback
    # @param [Image] image
    # @param [Proc<Image, FFI::Pointer>] callback
    # @param [FFI::Pointer] userdata
    # @return [Symbol] error code
    # @method image_add_load_callback(image, callback, userdata)
    attach_function :image_add_load_callback, [ Image, :image_loaded_cb, :userdata ], :error

    # Remove an image load callback previously added with {#image_add_load_callback}.
    #
    # @see #image_add_load_callback
    # @param [Image] image
    # @param [Proc<Image, FFI::Pointer>] callback
    # @param [FFI::Pointer] userdata
    # @return [Symbol] error code
    # @method image_remove_load_callback(image, callback, userdata)
    attach_function :image_remove_load_callback, [ Image, :image_loaded_cb, :userdata ], :error

    # @note Images that don't exist in Spotify can also return true.
    # @param [Image] image
    # @return [Boolean] true if the image information has been retrieved
    # @method image_is_loaded(image)
    attach_function :image_is_loaded, [ Image ], :bool

    # @param [Image] image
    # @return [Symbol] image error code
    # @method image_error(image)
    attach_function :image_error, [ Image ], :error

    # @see #image_is_loaded
    # @note the image must be loaded, or this function always return :unknown.
    # @param [Image] image
    # @return [Symbol] image format, one of :unknown, or :jpeg
    # @method image_format(image)
    attach_function :image_format, [ Image ], :imageformat

    # Retrieves raw image data.
    #
    # @example
    #   Spotify.image_data(image) # => "\xFF\xD8\xFF\xE0…
    #
    # @see #image_is_loaded
    # @note the image must be loaded, or this function always return nil.
    # @param [Image] image
    # @return [String, nil] raw image data, or nil if no image data available
    # @method image_data(image)
    attach_function :image_data, [ Image, :buffer_out ], :pointer do |image|
      FFI::Buffer.alloc_out(:size_t) do |image_size_pointer|
        data_pointer = sp_image_data(image, image_size_pointer)

        unless data_pointer.null?
          image_size = image_size_pointer.read_size_t
          return data_pointer.read_string(image_size) if image_size > 0
        end
      end
    end

    # @param [Image] image
    # @return [String] image id
    # @method image_image_id(image)
    attach_function :image_image_id, [ Image ], ImageID

    # @param [Session] session
    # @param [Link] link
    # @return [Image, nil] image pointed to by link, or nil if link is not a valid image link
    # @method image_create_from_link(session, link)
    attach_function :image_create_from_link, [ Session, Link ], Image

    attach_function :image_add_ref, [ Image ], :error
    attach_function :image_release, [ Image ], :error
  end
end
