module Spotify
  class API
    # !@group Inbox
    attach_function :inbox_post_tracks, [ Session, UTF8String, :array, :int, UTF8String, :inboxpost_complete_cb, :userdata ], Inbox
    attach_function :inbox_error, [ Inbox ], :error
    attach_function :inbox_add_ref, [ Inbox ], :error
    attach_function :inbox_release, [ Inbox ], :error
  end
end
