describe "Spotify::API" do
  describe "#link_as_string" do
    let(:link) { double }

    it "reads the link as an UTF-8 encoded string" do
      api.should_receive(:sp_link_as_string).twice do |ptr, buffer, buffer_size|
        ptr.should eq(link)
        buffer.write_bytes("spotify:user:burgestrandX") if buffer
        24
      end

      string = api.link_as_string(link)
      string.should eq "spotify:user:burgestrand"
      string.encoding.should eq(Encoding::UTF_8)
    end
  end

  describe "#link_as_track_and_offset" do
    let(:link) { double }
    let(:track) { double }

    it "reads the link as a track with offset information" do
      api.should_receive(:sp_link_as_track_and_offset) do |ptr, offset_pointer|
        ptr.should eq(link)
        offset_pointer.write_int(6000)
        track
      end

      api.link_as_track_and_offset(link).should eq([track, 6000])
    end

    it "returns nil if the link is not a track link" do
      api.should_receive(:sp_link_as_track_and_offset) do |ptr, offset_pointer|
        nil
      end

      api.link_as_track_and_offset(link).should be_nil
    end
  end
end
