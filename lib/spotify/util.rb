class << SpotifyAPI
  # @!group Utility

  # Retrieves the associated value of an enum from a given symbol, raising an error if it does not exist.
  #
  # @example retrieving a value
  #    SpotifyAPI.enum_value!(:ok, "error value") # => 0
  #
  # @example failing to retrieve a value
  #    SpotifyAPI.enum_value!(:moo, "connection rule") # => ArgumentError, invalid connection rule: :moo
  #
  # @param [Symbol] symbol
  # @param [#to_s] type used as error message when the symbol does not resolve
  # @raise [ArgumentError] when the symbol does not exist as an enum value
  def enum_value!(symbol, type)
    enum_value(symbol) or raise ArgumentError, "invalid #{type}: #{symbol}"
  end

  # @see platform
  # @return [Boolean] true if on Linux
  def linux?
    platform == :linux
  end

  # @return [Symbol] platform as either :mac, :windows, or :linux
  def platform
    case FFI::Platform::OS
    when /darwin/ then :mac
    when /linux/  then :linux
    when /mswin/  then :windows
    else
      $stderr.puts "[WARN] You are running the Spotify gem on an unknown platform. (#{__FILE__}:#{__LINE__})"
      :unknown
    end
  end
end
