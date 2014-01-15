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
Spotify.session_login($session, $username, $password, false, $blob)

$logger.info "Log in requested. Waiting forever until logged in."
Support.poll($session) { Spotify.session_connectionstate($session) == :logged_in }

$logger.info "Logged in as #{Spotify.session_user_name($session)}."

username = Support.prompt("Please enter a username", "burgestrand")

# libspotify has no way of searching for users by name or e-mail, so
# this is the only way I know of to get a handle of a user from nothing,
# and probably won't work for users that do not have a classic Spotify
# username, i.e. users that only signed up through Facebook.
#
# If you can get a handle on a playlist created by that user, you'll be
# able to get the handle for them, but not otherwise!
#
# For users that signed up through Facebook only, I believe their Facebook
# user ID should work with this lookup.
user_link = "spotify:user:#{username}"
link = Spotify.link_create_from_string(user_link)

if link.null?
  $logger.error "#{user_link} was apparently not parseable as a Spotify URI. Aborting."
  abort
end

user = Spotify.link_as_user(link)

$logger.info "Attempting to load user. Waiting forever until successful."
Support.poll($session) { Spotify.user_is_loaded(user) }

$logger.info "User loaded: #{Spotify.user_display_name(user)}."

$logger.info "Loading user playlists by loading their published container."
container = Spotify.session_publishedcontainer_for_user_create($session, Spotify.user_canonical_name(user))

$logger.info "Attempting to load container. Waiting forever until successful."
Support.poll($session) { Spotify.playlistcontainer_is_loaded(container) }

num_playlists = Spotify.playlistcontainer_num_playlists(container)
$logger.info "Container loaded. #{num_playlists} playlists in it!"

num_playlists.times do |index|
  $logger.info "Attempting to playlist #{index}. Waiting forever until successful."
  playlist = Spotify.playlistcontainer_playlist(container, index)
  Support.poll($session) { Spotify.playlist_is_loaded(playlist) }

  # Retrieving link for playlist, not yet done:
  # playlist_link = Spotify.link_create_from_playlist(playlist)
  # link_length = Spotify.link_as_string(playlist_link, nil, 0)
  # link_buffer = FFI::Buffer.alloc_out(length + 1)
  # Spotify.link_as_string(playlist_link, link_buffer, link_buffer.size)
  # link_string = link_buffer.read_string.force_encoding("UTF-8")

  $logger.info "  #{Spotify.playlist_name(playlist)}"
end

$logger.info "All done."
