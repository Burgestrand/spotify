describe "Spotify enums" do
  describe "audio sample types" do
    Spotify.enum_type(:sampletype).symbols.each do |symbol|
      specify "#{symbol} has a reader in FFI" do
        FFI::Pointer.new(1).should respond_to "read_array_of_#{symbol}"
      end
    end
  end
end
