#!/usr/bin/env ruby
# encoding: utf-8

require_relative "support"

session = Support.initialize_spotify!

artist_uri = Support.prompt("Please enter an artist URI to start with", "spotify:artist:7sVQKNtdP2NylxMgbNOJMM")
link = Spotify.link_create_from_string(artist_uri)

if link.null?
  $logger.error "Invalid URI. Aborting."
  abort
elsif (link_type = Spotify.link_type(link)) != :artist
  $logger.error "Was #{link_type} URI. Needs artist. Aborting."
  abort
end

target = Spotify.link_as_artist(link)

# Spotify.enum & :no_tracks & :no_albums
no_tracks = Spotify::Util.enum_value!(:no_tracks, "album type")
no_albums = Spotify::Util.enum_value!(:no_albums, "album type")
$dummy_callback = proc { }

artists = Set.new
count = 0

while target
  $logger.info "Stats: #{artists.length} artists, #{count} browses."

  browser = Spotify.artistbrowse_create(session, target, no_tracks | no_albums, $dummy_callback, nil)

  Support.poll(session) do
    Spotify.try(:artistbrowse_error, browser)
    Spotify.artistbrowse_is_loaded(browser)
  end

  similar_artists = Spotify.artistbrowse_num_similar_artists(browser).times.map do |index|
    Spotify.artistbrowse_similar_artist(browser, index)
  end

  similar_artists_names = similar_artists.map { |artist| Spotify.artist_name(artist) }

  target = similar_artists.sample
  artists << Spotify.artist_name(target)
  count += 1
end
