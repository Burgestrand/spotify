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
  compress_playlists: true,
  dont_save_metadata_for_playlists: true,
  initially_unload_playlists: false
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
$logger.info "Attempting to load #{user_link}. Waiting forever until successful."
Support.poll($session) { Spotify.user_is_loaded(user) }

display_name = Spotify.user_display_name(user)
canonical_name = Spotify.user_canonical_name(user)
$logger.info "User loaded: #{display_name}."

$logger.info "Loading user playlists by loading their published container: #{canonical_name}."
container = Spotify.session_publishedcontainer_for_user_create($session, canonical_name)

$logger.info "Attempting to load container. Waiting forever until successful."
Support.poll($session) { Spotify.playlistcontainer_is_loaded(container) }

$logger.info "Container loaded. Loading playlists until no more are loaded for three tries!"

container_size = 0
previous_container_size = 0
break_counter = 0

loop do
  container_size = Spotify.playlistcontainer_num_playlists(container)
  new_playlists = container_size - previous_container_size
  previous_container_size = container_size
  $logger.info "Loaded #{new_playlists} more playlists."

  # If we have loaded no new playlists for 4 tries, we assume we are done.
  if new_playlists == 0
    break_counter += 1
    if break_counter >= 4
      break
    end
  end

  $logger.info "Loading…"
  5.times do
    Support.process_events($session)
    sleep 0.2
  end
end

$logger.info "#{container_size} published playlists for #{display_name} found. Loading each playlists and printing it."
container_size.times do |index|
  type = Spotify.playlistcontainer_playlist_type(container, index)
  playlist = Spotify.playlistcontainer_playlist(container, index)
  Support.poll($session) { Spotify.playlist_is_loaded(playlist) }

  playlist_name = Spotify.playlist_name(playlist)
  num_tracks = Spotify.playlist_num_tracks(playlist)

  # Retrieving link for playlist:
  playlist_link = Spotify.link_create_from_playlist(playlist)
  link_string = if playlist_link.null?
    "(no link)"
  else
    link_length = Spotify.link_as_string(playlist_link, nil, 0)
    link_buffer = FFI::Buffer.alloc_out(link_length + 1)
    Spotify.link_as_string(playlist_link, link_buffer, link_buffer.size)
    link_buffer.get_string(0).force_encoding("UTF-8")
  end

  $logger.info "  (#{type}) #{playlist_name}: #{link_string} (#{num_tracks} tracks)"
end

$logger.info "All done."
