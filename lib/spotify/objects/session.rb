module Spotify
  # Session pointers are special in that they are created once,
  # never increases or decreases in reference count and should
  # never be released.
  #
  # See the {ManagedPointer} for documentation.
  class Session < ManagedPointer
    # After initialization sets autorelease to false.
    #
    # @param (see ManagedPointer)
    def initialize(*)
      super
      self.autorelease = false
    end
  end
end
