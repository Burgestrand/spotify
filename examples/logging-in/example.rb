#!/usr/bin/env ruby
# encoding: utf-8

require 'spotify'
require 'logger'

$logger = Logger.new($stderr)

#
# Some utility.
#

def poll(session)
  until yield
    process_events(session)
    sleep(0.01)
  end
end

def process_events(session)
  FFI::MemoryPointer.new(:int) do |ptr|
    Spotify.session_process_events(session, ptr)
    return Rational(ptr.read_int, 1000)
  end
end

def env(name)
  ENV.fetch(name) do
    raise "Missing ENV['#{name}']. Please: export #{name}='your value'"
  end
end

#
# Global callback procs.
#
# They are global variables to protect from ever being garbage collected.
# Not like they would in this script, but still.

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
  Spotify.try(:session_create, config, ptr)
  $session = Spotify::Session.new(ptr.read_pointer)
end

$logger.info "Created! Logging in."
Spotify.session_login($session, env('SPOTIFY_USERNAME'), env('SPOTIFY_PASSWORD'), false, nil)

$logger.info "Log in requested. Waiting forever until logged in."
poll($session) { Spotify.session_connectionstate($session) == :logged_in }

$logger.info "Logged in as #{Spotify.session_user_name($session)}."
