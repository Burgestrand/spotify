#!/usr/bin/env ruby
# encoding: utf-8

require "bundler/setup"
require "spotify"
require "logger"
require "json"
require "pry"
require "plaything"

Thread.abort_on_exception = true

# We use a logger to print some information on when things are happening.
$logger = Logger.new($stderr)
$logger.level = Logger::INFO

# libspotify supports callbacks, but they are not useful for waiting on
# operations (how they fire can be strange at times, and sometimes they
# might not fire at all). As a result, polling is the way to go.
def poll(session)
  until yield
    FFI::MemoryPointer.new(:int) do |ptr|
      Spotify.session_process_events(session, ptr)
    end
    sleep(0.1)
  end
end

# For making sure fetching configuration options fail with a useful error
# message when running the examples.
def env(name)
  ENV.fetch(name) do
    raise "Missing ENV[#{name}]. Please: export #{name}=\"your value\""
  end
end

def play_track(uri)
  link = Spotify.link_create_from_string(uri)
  track = Spotify.link_as_track(link)
  poll($session) { Spotify.track_is_loaded(track) }
  Spotify.try(:session_player_play, $session, false)
  Spotify.try(:session_player_load, $session, track)
  Spotify.try(:session_player_play, $session, true)
end

class FrameReader
  include Enumerable

  def initialize(channels, sample_type, frames_count, frames_ptr)
    @channels = channels
    @sample_type = sample_type
    @size = frames_count * @channels
    # strip type information, we work with bytes
    @pointer = FFI::Pointer.new(frames_ptr)
  end

  attr_reader :size

  def each
    return enum_for(__method__) unless block_given?

    ffi_read = :"get_#{@sample_type}"
    ffi_size = FFI.type_size(@sample_type)

    (0...size).each do |index|
      yield @pointer.public_send(ffi_read, index * ffi_size)
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
      plaything.stop
      $logger.debug("session (player)") { "music delivery audio discontuity" }
    else
      frames = FrameReader.new(format[:channels], format[:sample_type], num_frames, frames)
      consumed_samples = plaything << frames
      consumed_frames = consumed_samples / format[:channels]
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
config = Spotify::SessionConfig.new({
  api_version: Spotify::API_VERSION.to_i,
  application_key: IO.read("./spotify_appkey.key"),
  cache_location: ".spotify/",
  settings_location: ".spotify/",
  tracefile: "spotify_tracefile.txt",
  user_agent: "spotify for ruby",
  callbacks: Spotify::SessionCallbacks.new($session_callbacks),
})

$logger.info "Creating session."
FFI::MemoryPointer.new(Spotify::Session) do |ptr|
  Spotify.try(:session_create, config, ptr)
  $session = Spotify::Session.new(ptr.read_pointer)
end

$logger.info "Created! Logging in."
Spotify.session_login($session, env("SPOTIFY_USERNAME"), env("SPOTIFY_PASSWORD"), false, nil)

$logger.info "Log in requested. Waiting forever until logged in."
poll($session) { Spotify.session_connectionstate($session) == :logged_in }

$logger.info "Logged in as #{Spotify.session_user_name($session)}."

print "Spotify track URI: "
play_track gets.chomp

$logger.info "Playing track until end. Use ^C to exit."
poll($session) { $end_of_track }
