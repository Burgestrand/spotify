module Spotify
  # used to find the actual type of a thing
  def self.resolve_type(type)
    if type.is_a?(Class) and type <= Spotify::ManagedPointer
      type
    else
      type = find_type(type)
      type = type.type if type.respond_to?(:type)
      type
    end
  end

  # @return [Array<FFI::Struct>] all structs in Spotify namespace
  def self.structs
    constants.select { |x| const_get(x).is_a?(Class) && const_get(x) < FFI::Struct }
  end
end
