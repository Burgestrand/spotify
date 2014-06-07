describe Spotify::ByteString do
  describe ".to_native" do
    it "returns a memory pointer containing the given string, without ending NULL byte" do
      pointer = Spotify::ByteString.to_native("coolio", nil)
      pointer.size.should eq 6
    end

    it "returns nil when given nil" do
      pointer = Spotify::ByteString.to_native(nil, nil)
      pointer.should be_nil
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
      value.should eql pointer
    end
  end
end
