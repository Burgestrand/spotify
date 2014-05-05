module Spotify
  class API
    # @!group User

    # @param [User] user
    # @return [String] canonical username of user, the one used by Spotify in just about all places
    # @method user_canonical_name(user)
    attach_function :user_canonical_name, [ User ], UTF8String

    # @note #user_is_loaded can return true even if libspotify does not know the display name yet.
    # @note if libspotify does not have a display name, the function will return the canonical name of the user.
    # @param [User] user
    # @return [String] display name of user
    # @method user_display_name(user)
    attach_function :user_display_name, [ User ], UTF8String

    # @note the function may return true, even if display name is not yet known, make sure to {#session_process_events}!
    # @param [Track] track
    # @return [Boolean] true if user has finished loading
    # @method user_is_loaded(user)
    attach_function :user_is_loaded, [ User ], :bool

    attach_function :user_add_ref, [ User ], :error
    attach_function :user_release, [ User ], :error
  end
end
