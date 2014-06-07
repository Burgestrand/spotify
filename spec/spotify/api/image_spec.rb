describe "Spotify::API" do
  describe "#image_data" do
    let(:image) { double }

    it "reads the raw image data" do
      api.should_receive(:sp_image_data) do |img, img_size_pointer|
        img.should eq(image)
        img_size_pointer.write_size_t(8)
        FFI::MemoryPointer.from_string("image data")
      end

      api.image_data(image).should eq "image da"
    end

    it "is nil if image data is null" do
      api.should_receive(:sp_image_data) do |img, img_size_pointer|
        FFI::Pointer::NULL
      end

      api.image_data(image).should be_nil
    end

    it "is nil if image data size is 0" do
      api.should_receive(:sp_image_data) do |img, img_size_pointer|
        img_size_pointer.write_size_t(0)
        FFI::MemoryPointer.from_string("image data")
      end

      api.image_data(image).should be_nil
    end
  end
end
