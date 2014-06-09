#!/usr/bin/env ruby
# encoding: utf-8

require_relative "support"

require "json"
require "plaything"

def play_track(session, uri)
  link = Spotify.link_create_from_string(uri)
  track = Spotify.link_as_track(link)
  Support.poll(session) { Spotify.track_is_loaded(track) }

  # Pause before we load a new track. Fixes a quirk in libspotify.
  Spotify.try(:session_player_play, session, false)
  Spotify.try(:session_player_load, session, track)
  Spotify.try(:session_player_play, session, true)
end

class FrameReader
  include Enumerable

  def initialize(channels, sample_type, frames_count, frames_ptr)
    @channels = channels
    @sample_type = sample_type
    @size = frames_count * @channels
    @pointer = FFI::Pointer.new(@sample_type, frames_ptr)
  end

  attr_reader :size

  def each
    return enum_for(__method__) unless block_given?

    ffi_read = :"read_#{@sample_type}"

    (0...size).each do |index|
      yield @pointer[index].public_send(ffi_read)
    end
  end
end

plaything = Plaything.new

#
# Global callback procs.
#
# They are global variables to protect from ever being garbage collected.
#
# You must not allow the callbacks to ever be garbage collected, or libspotify
# will hold information about callbacks that no longer exist, and crash upon
# calling the first missing callback. This is *very* important!

$session_callbacks = {
  log_message: proc do |session, message|
    $logger.info("session (log message)") { message }
  end,

  logged_in: proc do |session, error|
    $logger.debug("session (logged in)") { Spotify::Error.explain(error) }
  end,

  logged_out: proc do |session|
    $logger.debug("session (logged out)") { "logged out!" }
  end,

  streaming_error: proc do |session, error|
    $logger.error("session (player)") { "streaming error %s" % Spotify::Error.explain(error) }
  end,

  start_playback: proc do |session|
    $logger.debug("session (player)") { "start playback" }
    plaything.play
  end,

  stop_playback: proc do |session|
    $logger.debug("session (player)") { "stop playback" }
    plaything.stop
  end,

  get_audio_buffer_stats: proc do |session, stats|
    stats[:samples] = plaything.queue_size
    stats[:stutter] = plaything.drops
    $logger.debug("session (player)") { "queue size [#{stats[:samples]}, #{stats[:stutter]}]" }
  end,

  music_delivery: proc do |session, format, frames, num_frames|
    if num_frames == 0
      $logger.debug("session (player)") { "music delivery audio discontuity" }
      plaything.stop
      0
    else
      frames = FrameReader.new(format[:channels], format[:sample_type], num_frames, frames)
      consumed_frames = plaything.stream(frames, format.to_h)
      $logger.debug("session (player)") { "music delivery #{consumed_frames} of #{num_frames}" }
      consumed_frames
    end
  end,

  end_of_track: proc do |session|
    $end_of_track = true
    $logger.debug("session (player)") { "end of track" }
    plaything.stop
  end,
}

#
# Main work code.
#

# You can read about what these session configuration options do in the
# libspotify documentation:
# https://developer.spotify.com/technologies/libspotify/docs/12.1.45/structsp__session__config.html
Support::DEFAULT_CONFIG[:callbacks] = Spotify::SessionCallbacks.new($session_callbacks)

session = Support.initialize_spotify!

play_track(session, Support.prompt("Spotify track URI", "spotify:track:5iIeIeH3LBSMK92cMIXrVD"))

$logger.info "Playing track until end. Use ^C to exit."
Support.poll(session) { $end_of_track }
