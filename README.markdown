libspotify FFI bindings for Ruby
================================
[libspotify](http://developer.spotify.com/en/libspotify/overview/) is a C library which allows developers to interact with the Spotify music streaming service. I wanted to be able to use this library in Ruby, and thus [Hallon](https://github.com/Burgestrand/Hallon) was born. Hallon, however, is more than just bindings to libspotify, it’s my attempt to make the API a joy to use. This is Ruby, after all!

Hallon recently changed from being a C extension to using [Ruby FFI](https://github.com/ffi/ffi), and in the process I created libspotify for Ruby. I decided to extract that work into its’ own gem, and here it is.

This is a very primitive library!
---------------------------------
There is no sugar-coating. When (if) you use this library you will practically be writing C, handling pointers and so on; only you’ll be doing it in Ruby.

If you want a library that is easier to use, have a look at [Hallon](https://github.com/Burgestrand/Hallon).

A note about versioning scheme
------------------------------
Given a version `X.Y.Z`, each segment corresponds to:

- X reflects supported libspotify version (0.0.7 => 7)
- Y is increased **only** on non-backwards-compatible bug fixes or feature additions
- Z is increased on backwards-compatible bug fixes or feature additions

When X increases (support for new libspotify versions) there are **no guarantees** of backwards-compatibility.

License
-------
X11 license, see the LICENSE document for details.