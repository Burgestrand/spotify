#!/usr/bin/env ruby
# encoding: utf-8

# NOTE: this example is merely here to count how fast audio frames
# can be delivered. It does not do anything useful.

require_relative "support"
require "json"

$frames = 0
$rate = 0

Support::DEFAULT_CONFIG[:callbacks] = Spotify::SessionCallbacks.new({
  music_delivery: proc do |session, format, frames, num_frames|
    $rate = format[:sample_rate]
    $frames += num_frames
    num_frames
  end,

  end_of_track: proc do |session|
    puts "End of track!"
    $end_of_track = true
  end
})

session = Support.initialize_spotify!

link = Spotify.link_create_from_string("spotify:track:1Lm5kdSQX6x1uVz6ep3AIk")
track = Spotify.link_as_track(link)

Support.poll(session) { Spotify.track_is_loaded(track) }

Spotify.try(:session_player_load, session, track)
Spotify.try(:session_player_play, session, true)

measurer = Thread.new do
  loop do
    if $rate
      frames, $frames = $frames, 0
      puts "#{frames}f of #{$rate}f/s (#{frames.fdiv($rate).round(2)}s)"
    end
    sleep 1
  end
end

$logger.info "Playing track until end. Use ^C to exit."
Support.silenced = true
Support.poll(session) { $end_of_track }
