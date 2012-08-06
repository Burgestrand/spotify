module Spotify
  class API
    # @!group Image
    attach_function :image_create, [ Session, ImageID ], Image
    attach_function :image_add_load_callback, [ Image, :image_loaded_cb, :userdata ], :error
    attach_function :image_remove_load_callback, [ Image, :image_loaded_cb, :userdata ], :error
    attach_function :image_is_loaded, [ Image ], :bool
    attach_function :image_error, [ Image ], :error
    attach_function :image_format, [ Image ], :imageformat
    attach_function :image_data, [ Image, :buffer_out ], :pointer
    attach_function :image_image_id, [ Image ], ImageID
    attach_function :image_create_from_link, [ Session, Link ], Image
    attach_function :image_add_ref, [ Image ], :error
    attach_function :image_release, [ Image ], :error
  end
end
