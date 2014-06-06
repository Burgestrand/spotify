module Spotify
  module MonkeyPatches
    module FFIBuffer
      def null?
        false
      end
    end

    ::FFI::Buffer.send(:include, FFIBuffer)
  end
end
