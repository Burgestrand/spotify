describe "Spotify::API" do
  describe "#image_data" do
    let(:image) { double }

    it "reads the raw image data" do
      expect(api).to receive(:sp_image_data) do |img, img_size_pointer|
        expect(img).to eq(image)
        img_size_pointer.write_size_t(8)
        FFI::MemoryPointer.from_string("image data")
      end

      expect(api.image_data(image)).to eq "image da"
    end

    it "is nil if image data is null" do
      expect(api).to receive(:sp_image_data) do |img, img_size_pointer|
        FFI::Pointer::NULL
      end

      expect(api.image_data(image)).to be_nil
    end

    it "is nil if image data size is 0" do
      expect(api).to receive(:sp_image_data) do |img, img_size_pointer|
        img_size_pointer.write_size_t(0)
        FFI::MemoryPointer.from_string("image data")
      end

      expect(api.image_data(image)).to be_nil
    end
  end
end
