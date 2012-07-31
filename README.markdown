Ruby bindings for [libspotify][] ([![Build Status](https://secure.travis-ci.org/Burgestrand/spotify.png?branch=master)](http://travis-ci.org/Burgestrand/spotify))
================================

    The libspotify C API package allows third party developers to write
    applications that utilize the Spotify music streaming service.

[Spotify][] is a really nice music streaming service, and being able to interact
with it in an API is awesome. libspotify itself is however written in C, making
it unavailable or cumbersome to use for many developers.

This project aims to allow Ruby developers access to all of the libspotify C API,
without needing to reach down to C. However, to use this library to it’s full extent
you will need to learn how to use the Ruby FFI API.

The Spotify gem has:

- 100% API coverage. You’ll be able to use any function from the libspotify library.
- Automatic garbage collection. It piggybacks on Ruby’s GC to manage pointer lifecycle.
- Basic utilities for error handling, with methods that raise automatically on errors.
- Callback support. Using this requires great care in how you manage your callback handlers.

The Spotify gem is aimed at experienced developers
--------------------------------------------------
As the raw libspotify API is exposed, the Spotify gem is best coupled with a supporting
library. This library would take a more focused approach to which kind of applications
you can write using it. The Spotify gem itself, however, has very few opinions.

Known supporting libraries:

- [Hallon](https://github.com/Burgestrand/Hallon), the original. Currently Hallon is simply
  a more convenient Spotify gem, written on top of the Spotify gem. It is diverging from its
  previous path, now towards a more focused and opinionated framework. If you’re unsure of
  what to use, start with the Hallon gem!

Do not let this stop you! Despite my harsh words the API is well suited for experimentation,
and it can be awfully fun to play with. If you need any assitance feel free to post a message
on the mailing list: [ruby-hallon@googlegroups.com][] (<https://groups.google.com/d/forum/ruby-hallon>).

Need help installing libspotify?
--------------------------------
You’re in luck! I’ve got you covered in Hallon’s wiki: [How to install libspotify](https://github.com/Burgestrand/Hallon/wiki/How-to-install-libspotify)!

A note about versioning scheme
------------------------------
Given a version `X.Y.Z`, each segment corresponds to:

- X reflects supported libspotify version (12.1.45 => 12). There are __no guarantees__ of backwards-compatibility!
- Y(major).Z(minor) follows [semantic versioning (semver.org)][]. Y is for backwards-**incompatible** changes, Z is for backwards-**compatible** changes.

License
-------
X11 license, see the LICENSE document for details.

[semantic versioning (semver.org)]: http://semver.org/
[ruby-hallon@googlegroups.com]: mailto:ruby-hallon@googlegroups.com
[libspotify]: http://developer.spotify.com/en/libspotify/overview/
[Spotify]: https://www.spotify.com/
[Hallon]: https://github.com/Burgestrand/Hallon
