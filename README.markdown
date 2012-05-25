Ruby FFI bindings for [libspotify][]
====================================

    The libspotify C API package allows third party developers to write
    applications that utilize the Spotify music streaming service.

[Spotify][] is a really nice music streaming service, and being able to interact with it in an API is awesome. However, because libspotify is a C library, writing applications with it is cumbersome and error-prone compared to doing it in Ruby. As I found myself needing to do this one day, knowing I’d rather not be writing it in C, this gem was born.

Spotify, the gem, is a thin layer of Ruby atop the [libspotify][] C library. It allows developers to use libspotify without writing a line of C, thanks to [Ruby FFI](https://rubygems.org/gems/ffi). Do note that there is no sugar-coating, and no attempts of abstraction will be made.

You want easy-to-use Ruby bindings for libspotify?
--------------------------------------------------
Then you should check out [Hallon][]! While libspotify-ruby is just the simplest bindings to libspotify possible, Hallon works really hard to make libspotify a joy to use in Ruby.

Finally, if you, for some reason, are having trouble deciding if you should use libspotify-ruby or Hallon, you should probably use Hallon.

(anecdotal note: this code base was previously a part of Hallon, but I decided to extract it and make a gem out of it)

[libspotify]: http://developer.spotify.com/en/libspotify/overview/
[Spotify]: https://www.spotify.com/
[Hallon]: https://github.com/Burgestrand/Hallon

Need help installing libspotify?
--------------------------------
You’re in luck! I’ve got you covered in the wiki, just [visit its main page](https://github.com/Burgestrand/libspotify-ruby/wiki)!

A note about versioning scheme
------------------------------
Given a version `X.Y.Z`, each segment corresponds to:

- X reflects supported libspotify version (12.1.45 => 12)
- Y is increased **only** on non-backwards-compatible bug fixes or feature additions
- Z is increased on backwards-compatible bug fixes or feature additions

When X increases (support for new libspotify versions) there are **no guarantees** of backwards-compatibility.

License
-------
X11 license, see the LICENSE document for details.
