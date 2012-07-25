describe Spotify::ImageID do
  let(:context) { nil }
  let(:subject) { Spotify.find_type(Spotify::ImageID) }
  let(:null_pointer) { FFI::Pointer::NULL }

  let(:image_id_pointer) do
    pointer = FFI::MemoryPointer.new(:char, 20)
    pointer.write_string(image_id)
    pointer
  end

  let(:image_id) do
    # deliberate NULL in middle of string
    image_id = ":\xD94#\xAD\xD9\x97f\xE0\x00V6\x05\xC6\xE7n\xD2\xB0\xE4P"
    image_id.force_encoding("BINARY")
    image_id
  end

  describe "from_native" do
    it "should be nil given a null pointer" do
      subject.from_native(null_pointer, context).should be_nil
    end

    it "should be an image id given a non-null pointer" do
      subject.from_native(image_id_pointer, context).should eq image_id
    end
  end

  describe "to_native" do
    it "should be a null pointer given nil" do
      subject.to_native(nil, context).should be_nil
    end

    it "should be a 20-byte C string given an actual string" do
      pointer = subject.to_native(image_id, context)
      pointer.read_string(20).should eq image_id_pointer.read_string(20)
    end

    it "should raise an error given more or less than a 20 byte string" do
      expect { subject.to_native(image_id + image_id, context) }.to raise_error(ArgumentError)
      expect { subject.to_native(image_id[0..10], context) }.to raise_error(ArgumentError)
    end
  end
end
