# encoding: utf-8
module Spotify
  # A regular string type, ending at the first NULL byte.
  #
  # Regular FFI :string raises errors when it encounters NULLs.
  module BestEffortString
    extend FFI::DataConverter
    native_type FFI::Type::STRING

    class << self
      # Extracts all of the string up until the first NULL byte.
      #
      # @param [String, nil] value
      # @param ctx
      # @return [String] value, up until the first NULL byte
      def to_native(value, ctx)
        value && value.dup.force_encoding(Encoding::BINARY)[/[^\x00]*/n]
      end
    end
  end
end
