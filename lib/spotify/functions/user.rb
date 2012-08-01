class SpotifyAPI
  # @!group User
  attach_function :user_canonical_name, [ User ], UTF8String
  attach_function :user_display_name, [ User ], UTF8String
  attach_function :user_is_loaded, [ User ], :bool
  attach_function :user_add_ref, [ User ], :error
  attach_function :user_release, [ User ], :error
end
