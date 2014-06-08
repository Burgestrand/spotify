module Spotify
  class API
    # @!group Inbox

    # Post an array of tracks to a Spotify user's inbox.
    #
    # @example
    #   callback = proc do |inbox|
    #     puts "Message posted."
    #   end
    #   inbox = Spotify.inbox_post_tracks(session, "burgestrand", tracks, "You must listen to these!", callback, nil)
    #
    # @param [Session] session
    # @param [String] username canonical username of recipient
    # @param [Array<Track>, Track] tracks
    # @param [String] message message to attach to post
    # @param [Proc<Inbox, FFI::Pointer] callback to call on completion
    # @param [FFI::Pointer] userdata
    # @return [Inbox]
    # @method inbox_post_tracks(session, username, tracks, message, callback, userdata)
    attach_function :inbox_post_tracks, [ Session, UTF8String, :array, :int, UTF8String, :inboxpost_complete_cb, :userdata ], Inbox do |session, username, tracks, message, callback, userdata|
      tracks = Array(tracks)

      with_buffer(Spotify::Track, size: tracks.length) do |tracks_buffer|
        tracks_buffer.write_array_of_pointer(tracks)
        sp_inbox_post_tracks(session, username, tracks_buffer, tracks.length, message, callback, userdata)
      end
    end

    # @param [Inbox] inbox
    # @return [Symbol] error status of inbox post
    # @method inbox_error(inbox)
    attach_function :inbox_error, [ Inbox ], :error

    attach_function :inbox_add_ref, [ Inbox ], :error
    attach_function :inbox_release, [ Inbox ], :error
  end
end
