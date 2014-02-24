#!/usr/bin/env ruby
# encoding: utf-8

require_relative "support"

session = Support.initialize_spotify!

$logger.info "Logged in as #{Spotify.session_user_name(session)}! Entering interactive session…"
binding.pry
