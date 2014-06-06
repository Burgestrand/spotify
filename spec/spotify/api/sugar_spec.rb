describe "Spotify::API" do
  describe "#image_data" do
    let(:image) { double }

    it "reads the raw image data" do
      api.should_receive(:sp_image_data) do |img, img_size_pointer|
        img.should eq(image)
        img_size_pointer.should be_a(FFI::Buffer)
        img_size_pointer.size.should eq(FFI.find_type(:size_t).size)

        img_size_pointer.write_size_t(8)
        FFI::MemoryPointer.from_string("image data")
      end

      Spotify.image_data(image).should eq "image da"
    end

    it "is nil if image data is null" do
      api.should_receive(:sp_image_data) do |img, img_size_pointer|
        FFI::Pointer::NULL
      end

      Spotify.image_data(image).should be_nil
    end

    it "is nil if image data size is 0" do
      api.should_receive(:sp_image_data) do |img, img_size_pointer|
        img_size_pointer.write_size_t(0)
        FFI::MemoryPointer.from_string("image data")
      end

      Spotify.image_data(image).should be_nil
    end
  end

  describe "#link_as_string" do
    let(:link) { double }

    it "reads the link as an UTF-8 encoded string" do
      api.should_receive(:sp_link_as_string).twice do |link, buffer, buffer_size|
        buffer.write_bytes("spotify:user:burgestrandX") if buffer
        24
      end

      string = Spotify.link_as_string(link)
      string.should eq "spotify:user:burgestrand"
      string.encoding.should eq(Encoding::UTF_8)
    end
  end
end
