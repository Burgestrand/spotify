# encoding: utf-8
require 'ffi'
require 'spotify/monkey_patches/ffi_pointer'
require 'spotify/monkey_patches/ffi_buffer'
require 'spotify/monkey_patches/ffi_enums'

require 'libspotify'
require 'performer'

require 'spotify/version'
require 'spotify/util'
require 'spotify/api'

# Spotify module allows you to place calls against the Spotify::API.
#
# @see method_missing method_missing on calling the API
# @see Spotify::API Spotify::API on available libspotify methods
# @see http://developer.spotify.com/en/libspotify/docs/ official libspotify documentation
module Spotify
  # @return [String] libspotify build ID.
  API_BUILD = Spotify::API.build_id

  unless API_BUILD.include?(Spotify::API_VERSION)
    warn "[WARNING:#{__FILE__}] libspotify v#{build_id} might be incompatible with ruby spotify v#{VERSION}(#{API_VERSION})"
  end

  @performer = Performer.new
  @__api__ = Spotify::API

  class << self
    # @see https://rubygems.org/gems/performer
    # @return [Performer]
    attr_reader :performer

    # Like send, but raises an error if the method returns a non-OK error.
    #
    # @example calling a method that returns an error
    #   Spotify.relogin(session) # => :invalid_indata
    #   Spotify.try(:relogin, session) # => raises APIError
    #
    # @note Works for non-error returning methods as well, it just does
    #       not do anything interesting.
    #
    # @param [#to_s] name
    # @param args
    # @raise [APIError] if an error other than :ok is returned
    def try(name, *args, &block)
      public_send(name, *args, &block).tap do |error|
        if error.is_a?(APIError)
          raise error unless error.is_a?(IsLoadingError)
        end
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
      @__api__.respond_to?(name, include_private)
    end

    # Calls the any method on the underlying {Spotify::API}.
    #
    # @example calling the API
    #    Spotify.link_create_from_string("spotify:user:burgestrand") # => #<Spotify::Link address=0x0deadbeef>
    #
    # @note Spotify protects all calls to {Spotify::API} by calling all
    #       API methods in the {.performer} thread.
    #
    # @param [Symbol, String] name
    # @param [Object, …] args
    def method_missing(name, *args, &block)
      if respond_to?(name)
        performer.sync { @__api__.public_send(name, *args, &block) }
      else
        super
      end
    end

    # Print debug messages, if $DEBUG is true.
    #
    # @param [String] message
    def log(message)
      $stdout.puts "[#{caller[0]}] #{message}" if $DEBUG
    end
  end
end
