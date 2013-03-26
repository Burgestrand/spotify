[HEAD][]
-----------
This release *also* breaks backwards-compatibilty, now all functions
accepting structs also have type-safety protection, similar to what
happens for pointers in v12.4.0.

- [a450bf27b9] implement type safety for all struct arguments
- [44b35d6432] automatic release for Subscribers struct

[v12.4.0][]
-----------
This release breaks backwards-compatibility, as functions will no
longer accept pointers of any other type of what they expect. This
means that you must wrap any pointers in a Spotify::ManagedPointer
of the appropriate type before using them to call API functions.

Callbacks now receive actual structs (by reference) in their params,
instead of a pointer which needed to be manually casted.

- [1fe1abed6] refactor retaining class for all managed pointer
- [af54c02e1] **naive type-checking for all spotify objects**
- [1d6939cd8] monkeypatch-add FFI::AbstractMemory#read_size_t
- [b9ce8941c] unlock mutex for Spotify::Error.explain (considered thread-safe)
- [fd2490728] add Spotify::Struct#to_s/to_h
- [1cbaf4a64] **callbacks now receive structs by reference instead of raw pointer**

[v12.3.0][]
-----------
Lots of internal and external changes. You could almost say it’s a rewrite.

- [0ee03487a] added a Spotify::ManagedPointer (new Spotify::AutoPointer) for every object
- [0ee03487a] all functions now always return auto pointers
- [a88920c22] it’s now possible to create a Spotify::Subscriber with a count
- [aa26b1ed2] have all callbacks retain their pointer
- [a72469b04] use new libspotify gem for attaching libspotify dynamic library
- renamed the repository from libspotify-ruby to spotify
- [345b47472] all structs can now be initialized with a hash
- [e54f1c806] SessionConfig now accepts string as application key
- [37f1f883d] Added Spotify.try(method), and removed bang-calling notation
- [6e51b6c4e] Added a mutex around every Spotify API call

I might’ve missed something. Read the commits for the nitty gritty.

[v12.2.0][]
-----------
- fix SessionConfig missing ca_certs_filename struct field on Linux

__v12.1.0__
-----------
- erroneously released (wrong version number, does not follow version policy)

[v12.0.3][]
-----------
- add support for search_playlist (retrieves a playlist object directly from a search)

[v12.0.2][]
-----------
- use error checking in Spotify::Pointer add_ref and release

[v12.0.1][]
-----------
- add Spotify::Pointer, a FFI::Pointer that manages spotify pointer refcount!
- wrap object-creating methods that returns Spotify::Pointers, e.g. albumbrowse_create!
- add error-checking variants of all functions that return an error e. g. session_relogin!
- add Spotify::Error with it’s .explain and .disambiguate

[v12.0.0][]
-----------
- upgrade to libspotify v12.1.45

[v11.0.2][]
-----------
- make the error message on missing functions more friendly
- fix changelog formatting

[v11.0.1][]
-----------
- upgrade to libspotify v11.1.60

[v11.0.0][]
-----------
- raise more helpful error on missing libspotify
- upgrade to libspotify v11.1.56

[v10.3.0][]
-----------
- map :image_id to a ruby string instead of a pointer

[v10.2.2][]
-----------
- allow non-UTF8 strings for link_create_from_string and login password

[v10.2.1][]
-----------
- make all strings (both input and output) be in UTF8

[v10.2.0][]
-----------
- make :sampletypes an array of *actual* FFI types that can be read

[v10.1.1][]
-----------
- mark ALL libspotify functions as blocking

[v10.1.0][]
-----------
- fix Spotify::Subscribers for empty subscribers
- Up FFI version dependency to v1.0.11 (Spotify::Bool is no more)

[v10.0.0][]
-----------
- upgrade to libspotify v10 (see changelog for details)

[v9.1.0][]
----------
- Spotify::Subscribers now supports retrieving members by array index

[v9.0.1][]
----------
- mark sp_session_player_load as blocking

[v9.0.0][]
----------
- upgrade to libspotify 9
- loosen up dependency version constraints

[v8.0.5][]
----------
- improve documentation and remove YARD plugin
- add specs for return type and argument types of functions
- fix return type and arguments for a bunch of functions
- add typedefs for spotify pointers (makes better docs)
- allow setting SessionConfig boolean values to true/false
- optimize by using `:buffer_out` where applicable

[v8.0.2][]
----------
- fix arguments of `image_create`

[v8.0.1][]
----------
- mark some session functions as blocking

[v8.0.0][]
----------
- upgrade to libspotify v0.0.8 compatibility
  - 96k bitrate
  - offline functionality
  - improved image support

[v7.0.4][]
----------
- improve documentation

[v7.0.3][]
----------
- adjust definitions for 1.8.7 compatibility

[v7.0.2][]
----------
- insignificant

[v7.0.1][]
----------
- participate in http://test.rubygems.org/

[v7.0.0][]
----------
- first release
- add all function definitions and structs

v0.0.0
------
- release to register rubygems.org name

[HEAD]: https://github.com/Burgestrand/spotify/compare/v12.3.0...HEAD

[v12.3.0]: https://github.com/Burgestrand/spotify/compare/v12.2.0...v12.3.0
[v12.2.0]: https://github.com/Burgestrand/spotify/compare/v12.0.3...v12.2.0
[v12.0.3]: https://github.com/Burgestrand/spotify/compare/v12.0.2...v12.0.3
[v12.0.2]: https://github.com/Burgestrand/spotify/compare/v12.0.1...v12.0.2
[v12.0.1]: https://github.com/Burgestrand/spotify/compare/v12.0.0...v12.0.1
[v12.0.0]: https://github.com/Burgestrand/spotify/compare/v11.0.2...v12.0.0
[v11.0.2]: https://github.com/Burgestrand/spotify/compare/v11.0.1...v11.0.2
[v11.0.1]: https://github.com/Burgestrand/spotify/compare/v11.0.0...v11.0.1
[v11.0.0]: https://github.com/Burgestrand/spotify/compare/v10.3.0...v11.0.0
[v10.3.0]: https://github.com/Burgestrand/spotify/compare/v10.2.2...v10.3.0
[v10.2.2]: https://github.com/Burgestrand/spotify/compare/v10.2.1...v10.2.2
[v10.2.1]: https://github.com/Burgestrand/spotify/compare/v10.2.0...v10.2.1
[v10.2.0]: https://github.com/Burgestrand/spotify/compare/v10.1.1...v10.2.0
[v10.1.1]: https://github.com/Burgestrand/spotify/compare/v10.1.0...v10.1.1
[v10.1.0]: https://github.com/Burgestrand/spotify/compare/v10.0.0...v10.1.0
[v10.0.0]: https://github.com/Burgestrand/spotify/compare/v9.1.0...v10.0.0
[v9.1.0]: https://github.com/Burgestrand/spotify/compare/v9.0.1...v9.1.0
[v9.0.1]: https://github.com/Burgestrand/spotify/compare/v9.0.0...v9.0.1
[v9.0.0]: https://github.com/Burgestrand/spotify/compare/v8.0.5...v9.0.0
[v8.0.5]: https://github.com/Burgestrand/spotify/compare/v8.0.2...v8.0.5
[v8.0.2]: https://github.com/Burgestrand/spotify/compare/v8.0.1...v8.0.2
[v8.0.1]: https://github.com/Burgestrand/spotify/compare/v8.0.0...v8.0.1
[v8.0.0]: https://github.com/Burgestrand/spotify/compare/v7.0.4...v8.0.0
[v7.0.4]: https://github.com/Burgestrand/spotify/compare/v7.0.3...v7.0.4
[v7.0.3]: https://github.com/Burgestrand/spotify/compare/v7.0.2...v7.0.3
[v7.0.2]: https://github.com/Burgestrand/spotify/compare/v7.0.1...v7.0.2
[v7.0.1]: https://github.com/Burgestrand/spotify/compare/v7.0.0...v7.0.1
[v7.0.0]: https://github.com/Burgestrand/spotify/compare/v0.0.0...v7.0.0
