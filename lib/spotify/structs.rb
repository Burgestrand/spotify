module Spotify
  # Spotify::Struct is a regular FFI::Struct, but with type
  # checking that happens in the Spotify::API namespace, and
  # it also allows you to initialize structs with a hash.
  class Struct < FFI::Struct
    # This is used by FFI to do type lookups when creating the
    # struct layout. By overriding this we can trick FFI into
    # looking up types in the right location.
    #
    # @return [Spotify::API]
    def self.enclosing_module
      Spotify::API
    end

    # When initialized with a hash, assigns each value of the
    # hash to the newly created struct before returning.
    #
    # If not given a hash, it behaves exactly as FFI::Struct.
    #
    # @param [#each_pair, FFI::Pointer, nil] pointer
    # @param [Array<Symbol, Type>] layout
    def initialize(pointer = nil, *layout, &block)
      if pointer.respond_to?(:each_pair)
        options = pointer
        pointer = nil
      else
        options = {}
      end

      super(pointer, *layout, &block)

      options.each_pair do |key, value|
        self[key] = value
      end
    end

    # Convert the struct to a hash.
    #
    # @return [Hash]
    def to_h
      Hash[members.zip(values)]
    end

    # String representation of the struct. Looks like a Hash.
    #
    # @return [String]
    def to_s
      "<#{self.class.name} #{to_h}>"
    end
  end
end

require 'spotify/structs/audio_buffer_stats'
require 'spotify/structs/audio_format'
require 'spotify/structs/offline_sync_status'
require 'spotify/structs/playlist_callbacks'
require 'spotify/structs/playlist_container_callbacks'
require 'spotify/structs/session_callbacks'
require 'spotify/structs/session_config'
require 'spotify/structs/subscribers'
