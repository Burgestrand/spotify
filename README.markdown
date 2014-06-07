Low-level Ruby bindings for [libspotify][], the official Spotify C API
======================================================================
[![Build Status](https://secure.travis-ci.org/Burgestrand/spotify.png?branch=master)](http://travis-ci.org/Burgestrand/spotify)
[![Dependency Status](https://gemnasium.com/Burgestrand/spotify.png)](https://gemnasium.com/Burgestrand/spotify)
[![Code Climate](https://codeclimate.com/github/Burgestrand/spotify.png)](https://codeclimate.com/github/Burgestrand/spotify)
[![Gem Version](https://badge.fury.io/rb/spotify.png)](http://badge.fury.io/rb/spotify)

    The libspotify C API package allows third party developers to write
    applications that utilize the Spotify music streaming service.

[Spotify][] is a really nice music streaming service, and being able to interact
with it in an API is awesome. libspotify itself is however written in C, making
it unavailable or cumbersome to use for many developers.

This project aims to allow Ruby developers access to all of the libspotify C API,
without needing to reach down to C. However, to use this library to its full extent
you will need to learn how to use the Ruby FFI API.

The Spotify gem has:

- [100% API coverage][], including callback support. You’ll be able to use any function from the libspotify library.
- [Automatic garbage collection][]. Piggybacking on Ruby’s GC to manage pointer lifecycle.
- [Parallell function call protection][]. libspotify is not thread-safe, but Spotify protects you by providing a re-entrant mutex around function calls.
- [Type conversion and type safety][]. Special pointers for every Spotify type, protecting you from accidental mix-ups.
- [Support for Ruby, JRuby and Rubinius][]. Thanks to FFI, the gem runs fine on the main three Ruby implementations!

[100% API coverage]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API
[Automatic garbage collection]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify/ManagedPointer
[Parallell function call protection]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify#method_missing-class_method
[Type conversion and type safety]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify/ManagedPointer
[Support for Ruby, JRuby and Rubinius]: https://github.com/Burgestrand/spotify/blob/master/.travis.yml

Contact details
---------------

- __Got questions?__ Ask on the mailing list: [ruby-spotify@googlegroups.com][] (<https://groups.google.com/d/forum/ruby-spotify>)
- __Found a bug?__ Report an issue: <https://github.com/Burgestrand/spotify/issues/new>
- __Have feedback?__ I ❤ feedback! Please send it to the mailing list.

Questions, notes and answers
----------------------------

### Links to keep close at hand when using libspotify

- [spotify gem API reference](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API) — YARDoc reference for the spotify gem, maps to the [libspotify function list](https://developer.spotify.com/docs/libspotify/12.1.51/api_8h.html).
- [libspotify C API reference](https://developer.spotify.com/docs/libspotify/12.1.51/) — the one true source of documentation.
- [libspotify FAQ](https://developer.spotify.com/technologies/libspotify/faq/) — you should read this at least once.
- [spotify gem examples](https://github.com/Burgestrand/spotify/tree/master/examples) — located in the spotify gem repository.
- [spotify gem FAQ](#questions-notes-and-answers) — this README section.


### How to run the examples

You’ll need:

1. Your [Spotify](http://spotify.com/) premium account credentials. If you sign in with Facebook, you’ll need your Facebook account e-mail and password.
2. Your [Spotify application key](https://developer.spotify.com/technologies/libspotify/keys/). Download the binary key, and put it in the `examples/` directory.

Running the examples is as simple as:

```
ruby example-audio_stream.rb
```

Available examples are:

- **example-audio_stream.rb**: plays songs from Spotify with the [plaything](https://github.com/Burgestrand/plaything) gem, using OpenAL.
- **example-console.rb**: logs in to Spotfify, and initiates a pry session to allow experimentation with the spotify gem API.
- **example-listing_playlists.rb**: list all playlists available for a certain user.
- **example-loading_object.rb**: loads a track using polling and the spotify gem API.
- **example-random_related_artists.rb**: looks up an artist and its similar artists on spotify, then it picks a similar artist at random and does the same to that artist, over and over. I have used this example file to test prolonged usage of the API.

### Creating a Session, the first thing you should do

Almost all functions require you to have created a session before calling them. Forgetting to do so won’t work at best, and will segfault at worst. You'll also want to log in before doing things as well, or objects will never load.

See [Spotify::API#session_create](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API#session_create-instance_method) for how to create a session.
See [Spotify::API#session_login](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API#session_login-instance_method) for logging in.

### libspotify is an asynchronous library

When creating objects in libspotify they are not populated with data instantly, instead libspotify schedules them for download from the Spotify backend. For libspotify to do it's work with downloading content, you need to call [Spotify::API#session_process_events](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API#session_process_events-instance_method) regularly.

### Facebook vs Spotify Classic

Users who signed up to Spotify with their Facebook account will have numeric IDs as usernames, so a link to their profile looks like [spotify:user:11101648092](spotify:user:11101648092). Spotify Classic users instead have their usernames as canonical name, so a link to their profile looks like [spotify:user:burgestrand](spotify:user:burgestrand).

This matters, for example, when you use the function [Spotify::API#session_publishedcontainer_for_user_create](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API#session_publishedcontainer_for_user_create-instance_method).

### Callbacks can be dangerous

libspotify allows you to pass callbacks that will be invoked by libspotify when events of interest occur, such as being logged out, or receiving audio data when playing a track.

Callbacks can be very tricky. They must never be garbage collected while they are in use by libspotify, or you may get very weird bugs with your Ruby interpreter randomly crashing. Do use them, but be careful.

### Opinions and the Spotify gem

The Spotify gem has very few opinions. It is build to closely resemble the libspotify C API, and has very little
to aid you in terms of how to structure your application. It aims to make calling the libspotify C API frictionless,
but not much more. It is up to you to decide your own path.

### A note about gem versioning

Given a version `X.Y.Z`, each segment corresponds to:

- `X` reflects supported libspotify version (12.1.45 => 12). There are __no guarantees__ of backwards-compatibility!
- `Y` is for backwards-**incompatible** changes.
- `Z` is for backwards-**compatible** changes.

You should use the following version constraint: `gem "spotify", "~> 12.5.3"`.


### Manually installing libspotify

By default, Spotify uses [the libspotify gem](https://rubygems.org/gems/libspotify) which means you do
not need to install libspotify yourself. However, if your platform is not supported by the libspotify
gem you will need to install libspotify yourself.

Please note, that if your platform is not supported by the libspotify gem I’d very much appreciate it
if you could create an issue on [libspotify gem issue tracker](https://github.com/Burgestrand/libspotify/issues)
so I can fix the build for your platform.

Instructions on installing libspotify manually are in the wiki: [How to install libspotify](https://github.com/Burgestrand/spotify/wiki)

[semantic versioning (semver.org)]: http://semver.org/
[ruby-spotify@googlegroups.com]: mailto:ruby-spotify@googlegroups.com
[libspotify]: https://developer.spotify.com/technologies/libspotify/
[Spotify]: https://www.spotify.com/
[Hallon]: https://github.com/Burgestrand/Hallon
