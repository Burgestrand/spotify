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

- [100% API coverage][], including callback support. You’ll be able to use any function from the libspotify library.
- [Automatic garbage collection][]. Piggybacking on Ruby’s GC to manage pointer lifecycle.
- [Parallell function call protection][]. libspotify is not thread-safe, but Spotify protects you.
- [Type conversion and type safety][]. Special pointers for every Spotify type, protecting you from accidental mix-ups.

[100% API coverage]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify/API
[Automatic garbage collection]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify/ManagedPointer
[Parallell function call protection]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify#method_missing-class_method
[Type conversion and type safety]: http://rdoc.info/github/Burgestrand/spotify/master/Spotify/ManagedPointer

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

Do not let this stop you! Despite my harsh words the Spotify API is well suited for experimentation,
and it can be awfully fun to play with. If you need any assitance feel free to post a message
on the mailing list: [ruby-hallon@googlegroups.com][] (<https://groups.google.com/d/forum/ruby-hallon>).

Manually installing libspotify
------------------------------
By default, Spotify uses [the libspotify gem](https://rubygems.org/gems/libspotify) which means you do
not need to install libspotify yourself. However, if your platform is not supported by the libspotify
gem you will need to install libspotify yourself.

Please note, that if your platform is not supported by the libspotify gem I’d very much appreciate it
if you could create an issue on [libspotify gem issue tracker](https://github.com/Burgestrand/libspotify/issues)
so I can fix the build for your platform.

While you’re waiting for the issue to resolve you could install libspotify manually. I’ve provided
instructions on how to do this in Hallon’s wiki: [How to install libspotify](https://github.com/Burgestrand/Hallon/wiki/How-to-install-libspotify)!

A note about versioning scheme
------------------------------
Given a version `X.Y.Z`, each segment corresponds to:

- X reflects supported libspotify version (12.1.45 => 12). There are __no guarantees__ of backwards-compatibility!
- Y(major).Z(minor) follows [semantic versioning (semver.org)][]. Y is for backwards-**incompatible** changes, Z is for backwards-**compatible** changes.

License
-------
Copyright (c) 2012 Kim Burgestrand <kim@burgestrand.se>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

[semantic versioning (semver.org)]: http://semver.org/
[ruby-hallon@googlegroups.com]: mailto:ruby-hallon@googlegroups.com
[libspotify]: http://developer.spotify.com/en/libspotify/overview/
[Spotify]: https://www.spotify.com/
[Hallon]: https://github.com/Burgestrand/Hallon
