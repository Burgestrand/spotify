module Spotify
  # Spotify::Struct allows us to initialize structs with a hash!
  class Struct < FFI::Struct
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
