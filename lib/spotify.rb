# encoding: utf-8
require 'ffi'
require 'libspotify'

# FFI bindings for libspotify.
#
# See official libspotify documentation for more detailed documentation about
# functions, types, errors, and library behavior.
#
# @see http://developer.spotify.com/en/libspotify/docs/
module Spotify
  class API
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

    def enum_type(*args, &block)
      self.class.enum_type(*args, &block)
    end

    def enum_value(*args, &block)
      self.class.enum_value(*args, &block)
    end
  end

  @__actor__ = Spotify::API.new

  class << self
    (instance_methods - [:object_id, :__send__, :method, :name, :to_s, :inspect, :constants, :const_get, :const_missing]).each do |m|
      undef_method(m)
    end

    # Like send, but raises an error if the method returns a non-OK error.
    #
    # @param [#to_s] name
    # @param *args
    # @raise [Spotify::Error] if an error other than :ok is returned
    def try(name, *args, &block)
      @__actor__.public_send(name, *args, &block).tap do |error|
        error, symbol = Spotify::Error.disambiguate(error)
        next if symbol.nil?
        next if symbol == :ok
        raise Error.new(symbol)
      end
    end

    def respond_to_missing?(name, include_private = false)
      @__actor__.respond_to?(name, include_private)
    end

    def method_missing(name, *args, &block)
      @__actor__.public_send(name, *args, &block)
    end
  end
end

require 'spotify/version'
require 'spotify/util'
require 'spotify/types'
require 'spotify/error'
require 'spotify/objects'
require 'spotify/defines'
require 'spotify/structs'
require 'spotify/api'
