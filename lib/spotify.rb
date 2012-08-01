# encoding: utf-8
require 'ffi'
require 'libspotify'

require 'spotify/version'
require 'spotify/util'
require 'spotify/types'
require 'spotify/error'

# FFI bindings for libspotify.
#
# See official libspotify documentation for more detailed documentation about
# functions, types, errors, and library behavior.
#
# @see http://developer.spotify.com/en/libspotify/docs/
class SpotifyAPI
  extend FFI::Library

  begin
    ffi_lib [LIBSPOTIFY_BIN, 'libspotify', '/Library/Frameworks/libspotify.framework/libspotify']
  rescue LoadError
    puts "Failed to load the `libspotify` library. Please make sure you have it
    installed, either globally on your system, in your LD_LIBRARY_PATH, or in
    your current working directory (#{Dir.pwd}).

    For installation instructions, please see:
      https://github.com/Burgestrand/Hallon/wiki/How-to-install-libspotify".gsub(/^ */, '')
    puts
    raise
  end
end

require 'spotify/objects'
require 'spotify/defines'
require 'spotify/structs'
require 'spotify/api'
