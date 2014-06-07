describe "Spotify::API" do
  describe "#playlist_get_image" do
    let(:playlist) { double }
    let(:image_id) { "v\xE5\xAA\xD3F\xF8\xEE4G\xA1.D\x9C\x85 \xC5\xFD\x80]\x99".force_encoding(Encoding::BINARY) }

    it "returns the image ID if playlist has an image" do
      api.should_receive(:sp_playlist_get_image) do |ptr, image_id_pointer|
        ptr.should eq(playlist)
        image_id_pointer.write_bytes(image_id)
        true
      end

      api.playlist_get_image(playlist).should eq(image_id)
    end

    it "returns nil if playlist has no image" do
      api.should_receive(:sp_playlist_get_image) do |ptr, image_id_pointer|
        false
      end

      api.playlist_get_image(playlist).should be_nil
    end
  end
end
