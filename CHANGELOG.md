[v11.0.1][]
- upgrade to libspotify v11.1.60

[v11.0.0][]
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

[v10.3.0]: https://github.com/Burgestrand/libspotify-ruby/compare/v10.2.2...v10.3.0
[v10.2.2]: https://github.com/Burgestrand/libspotify-ruby/compare/v10.2.1...v10.2.2
[v10.2.1]: https://github.com/Burgestrand/libspotify-ruby/compare/v10.2.0...v10.2.1
[v10.2.0]: https://github.com/Burgestrand/libspotify-ruby/compare/v10.1.1...v10.2.0
[v10.1.1]: https://github.com/Burgestrand/libspotify-ruby/compare/v10.1.0...v10.1.1
[v10.1.0]: https://github.com/Burgestrand/libspotify-ruby/compare/v10.0.0...v10.1.0
[v10.0.0]: https://github.com/Burgestrand/libspotify-ruby/compare/v9.1.0...v10.0.0
[v9.1.0]: https://github.com/Burgestrand/libspotify-ruby/compare/v9.0.1...v9.1.0
[v9.0.1]: https://github.com/Burgestrand/libspotify-ruby/compare/v9.0.0...v9.0.1
[v9.0.0]: https://github.com/Burgestrand/libspotify-ruby/compare/v8.0.5...v9.0.0
[v8.0.5]: https://github.com/Burgestrand/libspotify-ruby/compare/v8.0.2...v8.0.5
[v8.0.2]: https://github.com/Burgestrand/libspotify-ruby/compare/v8.0.1...v8.0.2
[v8.0.1]: https://github.com/Burgestrand/libspotify-ruby/compare/v8.0.0...v8.0.1
[v8.0.0]: https://github.com/Burgestrand/libspotify-ruby/compare/v7.0.4...v8.0.0
[v7.0.4]: https://github.com/Burgestrand/libspotify-ruby/compare/v7.0.3...v7.0.4
[v7.0.3]: https://github.com/Burgestrand/libspotify-ruby/compare/v7.0.2...v7.0.3
[v7.0.2]: https://github.com/Burgestrand/libspotify-ruby/compare/v7.0.1...v7.0.2
[v7.0.1]: https://github.com/Burgestrand/libspotify-ruby/compare/v7.0.0...v7.0.1
[v7.0.0]: https://github.com/Burgestrand/libspotify-ruby/compare/v0.0.0...v7.0.0
