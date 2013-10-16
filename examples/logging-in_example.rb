#!/usr/bin/env ruby
# encoding: utf-8

require_relative "example_support"

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

  credentials_blob_updated: lambda do |session, blob|
    $logger.info('session (blob)') { blob }
  end
}

#
# Main work code.
#

# You can read about what these session configuration options do in the
# libspotify documentation:
# https://developer.spotify.com/technologies/libspotify/docs/12.1.45/structsp__session__config.html
config = Spotify::SessionConfig.new({
  api_version: Spotify::API_VERSION.to_i,
  application_key: $appkey,
  cache_location: ".spotify/",
  settings_location: ".spotify/",
  user_agent: "spotify for ruby",
  callbacks: Spotify::SessionCallbacks.new($session_callbacks),
})

$logger.info "Creating session."
$session = Support.create_session(config)

$logger.info "Created! Logging in."
Spotify.session_login($session, $username, $password, false, $blob)

$logger.info "Log in requested. Waiting forever until logged in."
Support.poll($session) { Spotify.session_connectionstate($session) == :logged_in }

$logger.info "Logged in as #{Spotify.session_user_name($session)}."
