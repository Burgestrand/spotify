# coding: utf-8
require 'ffi'
require 'spotify/version'

# FFI wrapper around libspotify.
# 
# See official documentation for more detailed documentation about
# functions and their behavior.
# 
# @see http://developer.spotify.com/en/libspotify/docs/
module Spotify
  extend FFI::Library
  ffi_lib ['libspotify', '/Library/Frameworks/libspotify.framework/libspotify']
  
  # libspotify API version
  # @return [Fixnum]
  API_VERSION = VERSION.split('.').first.to_i
end