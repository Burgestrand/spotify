#!/usr/bin/env ruby
# encoding: utf-8

require_relative "support"

config = Spotify::SessionConfig.new({
  api_version: Spotify::API_VERSION.to_i,
  application_key: $appkey,
  cache_location: ".spotify/",
  settings_location: ".spotify/",
  user_agent: "spotify for ruby",
  callbacks: nil,
})

$logger.info "Creating session."
$session = Support.create_session(config)

$logger.info "Created! Logging in."
Spotify.session_login($session, $username, $password, false, nil)

$logger.info "Log in requested. Waiting forever until logged in."
Support.poll($session) { Spotify.session_connectionstate($session) == :logged_in }

$logger.info "Logged in as #{Spotify.session_user_name($session)}! Entering interactive session…"
binding.pry
