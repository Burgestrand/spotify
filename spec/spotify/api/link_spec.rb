describe "Spotify::API" do
  describe "#link_as_string" do
    let(:link) { double }

    it "reads the link as an UTF-8 encoded string" do
      expect(api).to receive(:sp_link_as_string).twice do |ptr, buffer, buffer_size|
        expect(ptr).to eq(link)
        buffer.write_bytes("spotify:user:burgestrandX") if buffer
        24
      end

      string = api.link_as_string(link)
      expect(string).to eq "spotify:user:burgestrand"
      expect(string.encoding).to eq(Encoding::UTF_8)
    end
  end

  describe "#link_as_track_and_offset" do
    let(:link) { double }
    let(:track) { double }

    it "reads the link as a track with offset information" do
      expect(api).to receive(:sp_link_as_track_and_offset) do |ptr, offset_pointer|
        expect(ptr).to eq(link)
        offset_pointer.write_int(6000)
        track
      end

      expect(api.link_as_track_and_offset(link)).to eq([track, 6000])
    end

    it "returns nil if the link is not a track link" do
      expect(api).to receive(:sp_link_as_track_and_offset) do |ptr, offset_pointer|
        nil
      end

      expect(api.link_as_track_and_offset(link)).to be_nil
    end
  end
end
