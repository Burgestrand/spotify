describe Spotify::NULString do
  describe ".to_native" do
    it "returns a memory pointer containing the given string" do
      pointer = Spotify::NULString.to_native("coolio", nil)
      pointer.read_string.should eq "coolio"
    end

    it "returns nil when given nil" do
      pointer = Spotify::NULString.to_native(nil, nil)
      pointer.should be_nil
    end

    it "raises an error when given a non-string" do
      expect { Spotify::NULString.to_native({}, nil) }
        .to raise_error(NoMethodError, /to_str/)
    end
  end

  describe ".from_native" do
    it "returns an empty string if given a null pointer" do
      value = Spotify::NULString.from_native(FFI::Pointer::NULL, nil)
      value.should be_nil
    end

    it "returns the string value of the string pointer" do
      pointer = FFI::MemoryPointer.from_string("hey")
      value = Spotify::NULString.from_native(pointer, nil)
      value.should eq "hey"
    end
  end
end
