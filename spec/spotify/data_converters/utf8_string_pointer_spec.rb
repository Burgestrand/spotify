# encoding: utf-8
describe Spotify::UTF8StringPointer do
  describe ".to_native" do
    it "returns a memory pointer containing the given string" do
      pointer = Spotify::UTF8StringPointer.to_native("coolio", nil)
      expect(pointer.read_string).to eq "coolio"
    end

    it "returns nil when given nil" do
      pointer = Spotify::UTF8StringPointer.to_native(nil, nil)
      expect(pointer).to be_nil
    end

    it "converts strings to UTF-8" do
      string = "åäö".encode("ISO-8859-1")
      pointer = Spotify::UTF8StringPointer.to_native(string, nil)

      expect(string.bytesize).to eq 3
      expect(pointer.read_string.bytesize).to eq 6
    end

    it "raises an error when given a non-string" do
      expect { Spotify::UTF8StringPointer.to_native({}, nil) }
        .to raise_error(NoMethodError, /to_str/)
    end
  end

  describe ".from_native" do
    it "returns an empty string if given a null pointer" do
      value = Spotify::UTF8StringPointer.from_native(FFI::Pointer::NULL, nil)
      expect(value).to be_nil
    end

    it "returns the string value of the string pointer" do
      pointer = FFI::MemoryPointer.from_string("hey")
      value = Spotify::UTF8StringPointer.from_native(pointer, nil)
      expect(value).to eq "hey"
    end

    it "forces the encoding to UTF-8" do
      string = FFI::MemoryPointer.from_string("åäö".encode("ISO-8859-1"))

      value = Spotify::UTF8StringPointer.from_native(string, nil)
      expect(value.bytesize).to eq 3
      expect(value.encoding).to eq Encoding::UTF_8
      expect(value).not_to be_valid_encoding
    end
  end
end
