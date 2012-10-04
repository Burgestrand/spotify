# How to run the examples:

1. Install the dependencies. Preferrably via bundler with `bundle install`.
2. Configure your environment variables SPOTIFY\_USERNAME, SPOTIFY\_PASSWORD.
3. Download your binary application key from <https://developer.spotify.com/technologies/libspotify/keys/>.
4. Put your `spotify_appkey.key` application key in the example directory.
5. Run your specific example, e.g. `bundle exec ruby logging-in.rb`.

## Available examples and what they do

- **logging-in.rb**

  a fairly small example on how you could login with the spotify API. It
  has some callbacks to provide more information on what happens during
  the process.
