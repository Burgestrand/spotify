module Spotify
  # Some methods used in the implementation that makes the C calls
  # less insane to make.
  #
  # @private
  module APIHelpers
    module_function

    # Allocate some memory and yield it to the given block.
    #
    # @param type
    # @param [Hash] options
    # @option options [Integer] :size (1)
    # @option options [Boolean] :clear (false)
    def with_buffer(type, options = {})
      size = options.fetch(:size, 1)
      clear = options.fetch(:clear, false)

      if size > 0
        FFI::MemoryPointer.new(type, size, clear) do |buffer|
          return yield buffer, buffer.size
        end
      end
    end

    # Allocate some memory, specifically for a string, and yield it to the given block.
    #
    # @param [Integer] length
    # @param [Hash] options
    # @option options [Boolean] :clear (false)
    def with_string_buffer(length, *args)
      if length > 0
        with_buffer(:char, size: length + 1) do |buffer, size|
          error = yield buffer, size

          if error.is_a?(Symbol) and error != :ok
            ""
          else
            buffer.get_string(0, length).force_encoding(Encoding::UTF_8)
          end
        end
      else
        ""
      end
    end
  end
end
