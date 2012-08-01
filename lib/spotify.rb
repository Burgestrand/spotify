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
module Spotify
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

  # @!macro [attach] attach_function
  #   @!method $1(…)
  #     @!scope class
  #     @example method signature (shows arguments)
  #       $*
  #     @return [${-1}]
  #
  # Overloaded to ensure all methods are defined as blocking,
  # and they return a managed pointer with the correct refcount.
  #
  # @param [#to_s] name function name sans `sp_` prefix.
  # @param [Array] args
  # @param [Object] returns
  def self.attach_function(c_name = nil, name, args, returns)
    if returns.respond_to?(:retaining_class) && name !~ /create/
      returns = returns.retaining_class
    end

    options  = { :blocking => true }
    c_name ||= "sp_#{name}"
    super(name, c_name, args, returns, options)
  end

  # Now, make sure we have the right libspotify version.
  attach_function :build_id, [], UTF8String
  API_BUILD = Spotify.build_id

  unless API_BUILD.include?(API_VERSION)
    raise LoadError, "libspotify v#{build_id} is incompatible with ruby spotify v#{VERSION}(#{API_VERSION})"
  end
end

require 'spotify/objects'
require 'spotify/defines'
require 'spotify/structs'
require 'spotify/functions'
