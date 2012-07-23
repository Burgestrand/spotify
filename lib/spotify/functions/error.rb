module Spotify
  # !@group Error
  attach_function :error_message, [ :error ], UTF8String
end
