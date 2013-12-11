# encoding: utf-8
require 'ffi'
require 'spotify/monkey_patches/ffi_pointer'
require 'libspotify'
require 'monitor'
require 'spotify/reaper'

# Spotify module allows you to place calls against the Spotify::API.
#
# @see method_missing method_missing on calling the API
# @see Spotify::API Spotify::API on available libspotify methods
# @see http://developer.spotify.com/en/libspotify/docs/ official libspotify documentation
module Spotify
  # API is the class which has all libspotify functions attached.
  #
  # All functions are attached as both instance methods and class methods, mainly
  # because that’s how FFI works it’s magic with attach_function. However, as this
  # is a class it allows to be instantiated.
  #
  # @note The API is private because this class is an implementation detail.
  #
  # @note You should never call any Spotify::API.method() directly, but instead
  #       you should call them via Spotify.method(). libspotify is not thread-safe,
  #       but it is documented to be okay to call the API from multiple threads *if*
  #       you only call one function at a time, which is ensured by the lock in the
  #       Spotify module.
  #
  # @api private
  class API
    extend FFI::Library

    begin
      ffi_lib [LIBSPOTIFY_BIN, 'spotify', 'libspotify', '/Library/Frameworks/libspotify.framework/libspotify']
      ffi_convention :stdcall if FFI::Platform.windows?
    rescue LoadError
      $stderr.puts <<-ERROR.gsub(/^ */, '')
        Failed to load the `libspotify` library. It is possible that the libspotify gem
        does not exist for your platform, in which case you’ll need to install it manually.

        For manual installation instructions, please see:
          https://github.com/Burgestrand/Hallon/wiki/How-to-install-libspotify
      ERROR
      raise
    end
  end

  @__api__ = Spotify::API
  @__api__.extend(MonitorMixin)

  class << self
    # Like send, but raises an error if the method returns a non-OK error.
    #
    # @example calling a method that returns an error
    #   Spotify.relogin(session) # => :invalid_indata
    #   Spotify.try(:relogin, session) # => raises Spotify::Error
    #
    # @note Works for non-error returning methods as well, it just does
    #       not do anything interesting.
    #
    # @param [#to_s] name
    # @param args
    # @raise [Spotify::Error] if an error other than :ok is returned
    def try(name, *args, &block)
      public_send(name, *args, &block).tap do |error|
        error, symbol = Spotify::Error.disambiguate(error)
        next if symbol.nil?
        next if symbol == :ok
        raise Error.new(symbol)
      end
    end

    # Asks the underlying Spotify API if it responds to `name`.
    #
    # @example
    #   Spotify.respond_to?(:error_message) # => true
    #
    # @example retrieving a method handle
    #   Spotify.metod(:error_message) # => #<Method: Spotify.error_message>
    #
    # @param [Symbol, String] name
    # @param [Boolean] include_private
    # @return [Boolean] true if the API supports the given method.
    def respond_to_missing?(name, include_private = false)
      @__api__.synchronize do
        @__api__.respond_to?(name, include_private)
      end
    end

    # Calls the any method on the underlying {Spotify::API}.
    #
    # @example calling the API
    #    Spotify.link_create_from_string("spotify:user:burgestrand") # => #<Spotify::Link address=0x0deadbeef>
    #
    # @note Spotify protects all calls to {Spotify::API} with a lock, so it is
    #       considered safe to call the API from different threads. The lock
    #       is re-entrant.
    #
    # @param [Symbol, String] name
    # @param [Object, …] args
    def method_missing(name, *args, &block)
      @__api__.synchronize do
        @__api__.send(name, *args, &block)
      end
    end

    # Print debug messages, if the given condition is true.
    #
    # @param [String] message
    # @param [Boolean] condition
    def log(message)
      $stdout.puts "[#{caller[0]}] #{message}" if $DEBUG
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
