describe Spotify::ByteString do
  describe ".to_native" do
    it "returns a memory pointer containing the given string, without ending NULL byte" do
      pointer = Spotify::ByteString.to_native("coolio", nil)
      expect(pointer.size).to eq 6
    end

    it "returns nil when given nil" do
      pointer = Spotify::ByteString.to_native(nil, nil)
      expect(pointer).to be_nil
    end

    it "raises an error when given a non-string" do
      expect { Spotify::ByteString.to_native({}, nil) }
        .to raise_error(NoMethodError, /to_str/)
    end
  end

  describe ".from_native" do
    it "returns the value, there is no size information" do
      pointer = FFI::MemoryPointer.from_string("hey")
      value = Spotify::ByteString.from_native(pointer, nil)
      expect(value).to eql pointer
    end
  end
end
