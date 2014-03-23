#!/usr/bin/env ruby
# encoding: utf-8

require_relative "support"

session = Support.initialize_spotify!

track_uri = Support.prompt("Please enter a track URI", "spotify:track:1612JQ4JxS8bm5ky53N3bH")
link = Spotify.link_create_from_string(track_uri)

if link.nil?
  $logger.error "Invalid URI. Aborting."
  abort
elsif (link_type = Spotify.link_type(link)) != :track
  $logger.error "Was #{link_type} URI. Needs track. Aborting."
  abort
else
  track = Spotify.link_as_track(link)
end

$logger.info "Attempting to load track. Waiting forever until successful."
Support.poll(session) { Spotify.track_is_loaded(track) }
$logger.info "Track loaded."

puts Spotify.track_name(track)
