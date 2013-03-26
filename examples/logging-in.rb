#!/usr/bin/env ruby
# encoding: utf-8

require "bundler/setup"
require "spotify"
require "logger"

# We use a logger to print some information on when things are happening.
$logger = Logger.new($stderr)

#
# Some utility.
#

# libspotify supports callbacks, but they are not useful for waiting on
# operations (how they fire can be strange at times, and sometimes they
# might not fire at all). As a result, polling is the way to go.
def poll(session)
  until yield
    FFI::MemoryPointer.new(:int) do |ptr|
      Spotify.session_process_events(session, ptr)
    end
    sleep(0.01)
  end
end

# For making sure fetching configuration options fail with a useful error
# message when running the examples.
def env(name)
  ENV.fetch(name) do
    raise "Missing ENV['#{name}']. Please: export #{name}='your value'"
  end
end

#
# Global callback procs.
#
# They are global variables to protect from ever being garbage collected.
#
# You must not allow the callbacks to ever be garbage collected, or libspotify
# will hold information about callbacks that no longer exist, and crash upon
# calling the first missing callback. This is *very* important!

$session_callbacks = {
  log_message: lambda do |session, message|
    $logger.info('session (log message)') { message }
  end,

  logged_in: lambda do |session, error|
    $logger.info('session (logged in)') { Spotify::Error.explain(error) }
  end,

  logged_out: lambda do |session|
    $logger.info('session (logged out)') { 'logged out!' }
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
  application_key: IO.read('./spotify_appkey.key'),
  cache_location: ".spotify/",
  settings_location: ".spotify/",
  tracefile: "spotify_tracefile.txt",
  user_agent: "spotify for ruby",
  callbacks: Spotify::SessionCallbacks.new($session_callbacks),
})

$logger.info "Creating session."
FFI::MemoryPointer.new(Spotify::Session) do |ptr|
  # Spotify.try is a special method. It raises a ruby exception if the returned spotify
  # error code is an error.
  Spotify.try(:session_create, config, ptr)
  $session = Spotify::Session.new(ptr.read_pointer)
end

$logger.info "Created! Logging in."
Spotify.session_login($session, env('SPOTIFY_USERNAME'), env('SPOTIFY_PASSWORD'), false, nil)

$logger.info "Log in requested. Waiting forever until logged in."
poll($session) { Spotify.session_connectionstate($session) == :logged_in }

$logger.info "Logged in as #{Spotify.session_user_name($session)}."
