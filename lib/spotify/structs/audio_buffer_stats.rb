module Spotify
  # Spotify::Struct for Audio Buffer Stats.
  #
  # @attr [Fixnum] samples
  # @attr [Fixnum] stutter
  class AudioBufferStats < Spotify::Struct
    layout :samples => :int,
           :stutter => :int
  end
end
