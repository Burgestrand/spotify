describe Spotify::UTF8StringPointer do
  describe ".to_native" do
    it "returns a memory pointer containing the given string" do
      pointer = Spotify::UTF8StringPointer.to_native("coolio", nil)
      pointer.read_string.should eq "coolio"
    end

    it "returns nil when given nil" do
      pointer = Spotify::UTF8StringPointer.to_native(nil, nil)
      pointer.should be_nil
    end

    it "converts strings to UTF-8" do
      string = "åäö".encode("ISO-8859-1")
      pointer = Spotify::UTF8StringPointer.to_native(string, nil)

      string.bytesize.should eq 3
      pointer.read_string.bytesize.should eq 6
    end

    it "raises an error when given a non-string" do
      expect { Spotify::UTF8StringPointer.to_native({}, nil) }
        .to raise_error(NoMethodError, /to_str/)
    end
  end

  describe ".from_native" do
    it "returns an empty string if given a null pointer" do
      value = Spotify::UTF8StringPointer.from_native(FFI::Pointer::NULL, nil)
      value.should be_nil
    end

    it "returns the string value of the string pointer" do
      pointer = FFI::MemoryPointer.from_string("hey")
      value = Spotify::UTF8StringPointer.from_native(pointer, nil)
      value.should eq "hey"
    end

    it "forces the encoding to UTF-8" do
      string = FFI::MemoryPointer.from_string("åäö".encode("ISO-8859-1"))

      value = Spotify::UTF8StringPointer.from_native(string, nil)
      value.bytesize.should eq 3
      value.encoding.should eq Encoding::UTF_8
      value.should_not be_valid_encoding
    end
  end
end
