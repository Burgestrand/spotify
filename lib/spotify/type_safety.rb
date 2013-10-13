module Spotify
  # Spotify::TypeSafety checks all values coming in and makes sure
  # they are of an instance of the correct {#type_class}.
  module TypeSafety
    # Convert given value to native value, with type checking.
    #
    # @note Calls super-implementation if type is safe.
    #
    # @param value
    # @param ctx
    # @raise [TypeError] if value is not of the same kind as {#type_class}.
    def to_native(value, ctx)
      if value.kind_of?(type_class)
        super
      else
        raise TypeError, "expected a kind of #{name}, was #{value.class}"
      end
    end

    # Retrieve the type that all objects going into to_native must be of.
    #
    # @return self by default
    def type_class
      self
    end
  end
end
