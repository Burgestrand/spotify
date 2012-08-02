module Spotify
  # Spotify::Struct for Audio Format.
  #
  # @attr [:sampletype] sample_type
  # @attr [Fixnum] sample_rate
  # @attr [Fixnum] channels
  class AudioFormat < Spotify::Struct
    layout :sample_type => :sampletype,
           :sample_rate => :int,
           :channels => :int
  end
end
