module Spotify
  class API
    # @!group Inbox

    # Post an array of tracks to a Spotify user's inbox.
    #
    # @example
    #   tracks = [track_one, track_two]
    #   tracks_pointer = FFI::MemoryPointer.new(Spotify::Track, tracks.length)
    #   tracks_pointer.write_array_of_pointer(tracks)
    #   callback = proc do |inbox|
    #     puts "Message posted."
    #   end
    #   inbox = Spotify.inbox_post_tracks(session, "burgestrand", tracks_pointer, tracks.length, "You must listen to these!", callback, nil)
    #
    # @param [Session] session
    # @param [String] username canonical username of recipient
    # @param [FFI::Pointer<Track>] tracks_pointer pointer to array of tracks
    # @param [Integer] tracks_pointer_count number of tracks in tracks_pointer
    # @param [String] message message to attach to post
    # @param [Proc<Inbox, FFI::Pointer] callback to call on completion
    # @param [FFI::Pointer] userdata
    # @return [Inbox]
    # @method inbox_post_tracks(session, username, tracks_pointer, tracks_pointer_count, message, callback, userdata)
    attach_function :inbox_post_tracks, [ Session, UTF8String, :array, :int, UTF8String, :inboxpost_complete_cb, :userdata ], Inbox

    # @param [Inbox] inbox
    # @return [Symbol] error status of inbox post
    # @method inbox_error(inbox)
    attach_function :inbox_error, [ Inbox ], :error

    attach_function :inbox_add_ref, [ Inbox ], :error
    attach_function :inbox_release, [ Inbox ], :error
  end
end
