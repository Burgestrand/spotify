describe "Spotify types" do
  describe "audio sample types" do
    Spotify::API.enum_type(:sampletype).symbols.each do |symbol|
      specify "#{symbol} has a reader in FFI" do
        FFI::Pointer.new(1).should respond_to "read_array_of_#{symbol}"
      end
    end
  end

  API_H_XML.enumerations.each do |enum|
    attached_enum = Spotify.enum_type enum["name"].sub(/\Asp_/, '').to_sym
    original_enum = enum.values.map { |v| [v["name"].downcase, v["init"]] }

    describe enum["name"] do
      it "should exist" do
        attached_enum.should_not be_nil
      end

      it "should match the definition" do
        attached_enum_map = attached_enum.symbol_map.dup
        original_enum.each do |(name, value)|
          a_name, a_value = attached_enum_map.max_by { |(n, _)| (n.to_s.length if name.match(n.to_s)).to_i }
          attached_enum_map.delete(a_name)
          a_value.to_s.should eq value
        end
      end
    end
  end
end
