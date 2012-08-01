describe SpotifyAPI::NULString do
  describe ".to_native" do
    it "returns a memory pointer containing the given string" do
      pointer = SpotifyAPI::NULString.to_native("coolio", nil)
      pointer.read_string.should eq "coolio"
    end

    it "returns a null pointer when given nil" do
      pointer = SpotifyAPI::NULString.to_native(nil, nil)
      pointer.should be_null
    end

    it "raises an error when given a non-string" do
      expect { SpotifyAPI::NULString.to_native({}, nil) }
        .to raise_error(TypeError)
    end
  end

  describe ".from_native" do
    it "returns an empty string if given a null pointer" do
      value = SpotifyAPI::NULString.from_native(FFI::Pointer::NULL, nil)
      value.should be_nil
    end

    it "returns the string value of the string pointer" do
      pointer = FFI::MemoryPointer.from_string("hey")
      value = SpotifyAPI::NULString.from_native(pointer, nil)
      value.should eq "hey"
    end
  end
end
