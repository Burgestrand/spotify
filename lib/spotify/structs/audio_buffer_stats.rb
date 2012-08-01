class SpotifyAPI
  # SpotifyAPI::Struct for Audio Buffer Stats.
  #
  # @attr [Fixnum] samples
  # @attr [Fixnum] stutter
  class AudioBufferStats < SpotifyAPI::Struct
    layout :samples => :int,
           :stutter => :int
  end
end
