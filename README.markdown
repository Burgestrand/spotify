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
- [Support for JRuby and Rubinius][]. Thanks to FFI, the gem runs fine on the main three Ruby implementations!

[100% API coverage]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API
[Automatic garbage collection]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify/ManagedPointer
[Parallell function call protection]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify#method_missing-class_method
[Type conversion and type safety]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify/ManagedPointer
[Support for JRuby and Rubinius]: https://github.com/Burgestrand/spotify/blob/master/.travis.yml

Contact details
---------------

- __Got questions?__ Ask on the mailing list: [ruby-hallon@googlegroups.com][] (<https://groups.google.com/d/forum/ruby-hallon>)
- __Found a bug?__ Report an issue: <https://github.com/Burgestrand/spotify/issues/new>
- __Have feedback?__ I ❤ feedback! Please send it to the mailing list.

Usage instructions
------------------

You’ll need:

1. A [Spotify](http://spotify.com/) premium account.
2. A [Spotify application key](https://developer.spotify.com/technologies/libspotify/keys/). Download the binary key.

Additionally, I urge you to keep the following links close at hand:

- [libspotify C API reference](https://developer.spotify.com/docs/libspotify/12.1.51/) — canonical source for documentation.
- [spotify gem API reference](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API) — YARDoc reference for the spotify gem, maps to the [libspotify function list][].
- [libspotify FAQ](https://developer.spotify.com/technologies/libspotify/faq/) — you should read this at least once.
- [spotify gem examples](https://github.com/Burgestrand/spotify/tree/master/examples) — located in the spotify gem repository.
- [spotify gem FAQ](#questions-notes-and-answers) — further down in this document.

Finally, before we start here are some cautionary notes:

- Almost all functions require you to have created a libspotify session before calling them. Forgetting to do so won’t work at best, and will segfault at worst.
- Callbacks must never be garbage collected as long as libspotify want to call them.

You are expected to read the libspotify C API reference for documentation on what function calls are available, and what they do. This may be scary, but you will be alright. Every function in the libspotify C API is available through the Spotify gem in Ruby, most of them as regular ruby methods on the Spotify module, just drop the `sp_` prefix.

### Calling conventions

There are a few different types of functions in the C API, and I’d like to take the time to illustrate how they translate into Ruby code.

- [sp_build_id](https://developer.spotify.com/docs/libspotify/12.1.51/api_8h.html#a181d0940997cb8b69869449cd826cf88), `const char* sp_build_id(void)`:  [Spotify.build_id](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API#build_id-instance_method)

  ```ruby
  Spotify.build_id # => "12.1.51"
  ```
  
  No parameters, returns a string. Drop the `sp_` prefix and call the equivalent Ruby method on the Spotify module.
  
- [sp_link_create_from_string](https://developer.spotify.com/docs/libspotify/12.1.51/group__link.html#gaea9c39f35f7986fc9fed4584fa211127), `sp_link *sp_link_create_from_string)(const char *link)`: [Spotify.link_create_from_string(string)](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API#link_create_from_string-instance_method)

  ```ruby
  link = Spotify.link_create_from_string("spotify:track:2YDnJ6HXIABg7LEh82ShjL") # => Spotify::Link
  ```
  
  The C function takes a string as parameter, and returns a link, and so does the Ruby method. Each libspotify pointer type has an equivalent Ruby class, sp_link to Spotify::Link, sp_track to Spotify::Track, and so on.
  
- [sp_error_message](https://developer.spotify.com/docs/libspotify/12.1.51/group__error.html#ga983dee341d3c2008830513b7cffe7bf3), `const char *sp_error_message(sp_error error)`: [Spotify.error_message](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API#error_message-instance_method)

  ```ruby
  Spotify.error_message(0) # => "No error"
  Spotify.error_message(:ok) # => "No error"
  ```

  `sp_error` is an enum, [according to the libspotify C documentation](https://developer.spotify.com/docs/libspotify/12.1.51/group__error.html), which means [it maps to symbols in the Spotify gem](https://github.com/Burgestrand/spotify/blob/master/lib/spotify/defines.rb#L10); we may pass either an integer or symbol value as parameter, i.e. `0` and `:ok` are equivalent as parameters.
  
  Familiar naming rules apply; drop the prefix and downcase the name, so `SP_ERROR_OK` in C becomes `:ok` in Ruby.
  
- [sp_track_error](https://developer.spotify.com/docs/libspotify/12.1.51/group__track.html#ga947c0f7755b0c4955ca0b0993db0f2b5), `sp_error sp_track_error(sp_track *track)`: [Spotify.track_error](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API#track_error-instance_method)

  ```ruby
  error = Spotify.track_error(track) # => :permission_denied
  Spotify.try(:track_error, track) # => throws Spotify::Error
  ```
  
  Some functions return an error code. Sometimes you may want to ignore the error code, or simply print it out. In other cases, an error means you should throw an exception and crash your application, and for these occasions you have [Spotify.try](http://rdoc.info/github/Burgestrand/spotify/master/Spotify#try-class_method).

- [sp_playlist_subscribers](https://developer.spotify.com/docs/libspotify/12.1.51/group__playlist.html#gad49f491babc475f8d4aeea1b4452ff8b), `sp_subscribers *sp_playlist_subscribers(sp_playlist *playlist)`: [Spotify.playlist_subscribers](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API#playlist_subscribers-instance_method)

  ```ruby
  subscribers = Spotify.playlist_subscribers(playlist) # => Spotify::Subscribers
  subscribers[:count] unless subscribers.null?
  subscribers.each do |subscriber_name|
    # do something with subscriber
  end
  ```

  `sp_subscribers*` [is a struct](https://developer.spotify.com/docs/libspotify/12.1.51/structsp__subscribers.html). You can access struct members through `struct[:member]`, and write to them with `struct[:member] = value`. Structs automatically free their pointer, so there is no need for you to manually call `Spotify.playlist_subscribers_free`, but if you really want to free the struct manually, call `struct.free` instead.

- [sp_session_create](https://developer.spotify.com/docs/libspotify/12.1.51/group__session.html#gaf2891f2daced4ff6da84219d6376b3aa), `sp_error sp_session_create(const sp_session_config *config, sp_session **sess)`: [Spotify.session_create](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API#session_create-instance_method)

  ```ruby
  config = Spotify::SessionConfig.new({
    api_version: Spotify::API_VERSION.to_i,
    application_key: File.binread("./spotify_appkey.key"),
    cache_location: "",
    user_agent: "spotify for ruby",
    callbacks: nil,
  })
  
  session = FFI::MemoryPointer.new(Spotify::Session) do |session_pointer|
    Spotify.try(:session_create, config, session_pointer)
    break Spotify::Session.new(session_pointer.read_pointer)
  end
  ```

  Functions can have multiple return values, and in these cases you are required to drop down to FFI-land. Here, session_create takes a config struct, and a *pointer* to where to store the newly created session. Once the call is complete, we must read the pointer that session_create stored *inside* session_pointer.
  
  Luckily, there are not too many of these tricky functions, and they all look about the same when you call them, but for different types. Have a look at session_process_events, for example:
  
  ```ruby
  timeout_ms = FFI::MemoryPointer.new(:int) do |int_pointer|
    Spotify.session_process_events(session, int_pointer)
    break int_pointer.read_int
  end
  ```
  
  Be careful: FFI::MemoryPointer.new does not return the value of the block, which is why break is used in the examples above to get a useful return value.
  
- [sp_albumbrowse_create](https://developer.spotify.com/docs/libspotify/12.1.51/group__albumbrowse.html#gaf1bc3042e748efea5ca7ac159e5cbfbe) (with [albumbrowse_complete_cb](https://developer.spotify.com/docs/libspotify/12.1.51/group__albumbrowse.html#gabd76254f89048e6d368929015a0c739f)), `sp_albumbrowse *sp_albumbrowse_create(sp_session *session, sp_album *album, albumbrowse_complete_cb *callback, void *userdata)`: [Spotify.albumbrowse_create](http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API#albumbrowse_create-instance_method)

  ```ruby
  $created_callback = proc do |album_browse|
    puts "Browsing complete!"
  end
  album_browse = Spotify.albumbrowse_create(session, album, $created_callback, nil) 
  ```
  
  Callbacks. Callbacks are tricky. If you pass a callback proc to libspotify, you must *never* garbage collect it as long as libspotify could still call it. This is why it is stored as a global above, to make sure it never disappears. Apart from that scary fact, callbacks do not have much to them. They take the same parameters as their C counterpart.
  
  Callbacks really easy to get wrong. If your code crashes with mysterious errors, and you use callbacks, that’s where you should look first for errors. If in doubt, ask on the mailing list.

[libspotify function list]: https://developer.spotify.com/docs/libspotify/12.1.51/api_8h.html
[Spotify.session_create]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API#session_create-instance_method
[examples]: examples

Questions, notes and answers
----------------------------

### A note about gem versioning

Given a version `X.Y.Z`, each segment corresponds to:

- `X` reflects supported libspotify version (12.1.45 => 12). There are __no guarantees__ of backwards-compatibility!
- `Y` is for backwards-**incompatible** changes.
- `Z` is for backwards-**compatible** changes.

You should use the following version constraint: `gem "spotify", "~> 12.5.3"`.

### How to run the examples

Follow the instructions for application key in [Usage instructions](#usage-instructions). Once that is finished, enter the examples directory, and run an example as follows:

```
SPOTIFY_USERNAME="your username" SPOTIFY_PASSWORD="your password" ruby example-logging_in.rb
```

Available examples are:

- **example-audio_stream.rb**: plays songs from Spotify with the [plaything](https://github.com/Burgestrand/plaything) gem, using OpenAL.
- **example-console.rb**: logs in to Spotfify, and initiates a pry session to allow experimentation with the spotify gem API.
- **example-loading_object.rb**: loads a track using polling and the spotify gem API.
- **example-logging_in.rb**: logs in to Spotify and prints the current user's username.
- **example-random_related_artists.rb**: looks up an artist and its similar artists on spotify, then it picks a similar artist at random and does the same to that artist, over and over. I have used this example file to test prolonged usage of the API.


### Opinions and the Spotify gem

The Spotify gem has very few opinions. It is build to closely resemble the libspotify C API, and has very little
to aid you in terms of how to structure your application. It aims to make calling the libspotify C API frictionless,
but not much more. It is up to you to decide your own path.

### Manually installing libspotify

By default, Spotify uses [the libspotify gem](https://rubygems.org/gems/libspotify) which means you do
not need to install libspotify yourself. However, if your platform is not supported by the libspotify
gem you will need to install libspotify yourself.

Please note, that if your platform is not supported by the libspotify gem I’d very much appreciate it
if you could create an issue on [libspotify gem issue tracker](https://github.com/Burgestrand/libspotify/issues)
so I can fix the build for your platform.

Instructions on installing libspotify manually are in the wiki: [How to install libspotify](https://github.com/Burgestrand/spotify/wiki)

[semantic versioning (semver.org)]: http://semver.org/
[ruby-hallon@googlegroups.com]: mailto:ruby-hallon@googlegroups.com
[libspotify]: https://developer.spotify.com/technologies/libspotify/
[Spotify]: https://www.spotify.com/
[Hallon]: https://github.com/Burgestrand/Hallon
