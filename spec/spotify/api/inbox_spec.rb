describe "Spotify::API" do
  describe "#inbox_post_tracks" do
    let(:session) { double }
    let(:callback) { lambda {} }
    let(:track_a) { FFI::MemoryPointer.new(:pointer) }
    let(:track_b) { FFI::MemoryPointer.new(:pointer) }
    let(:tracks) { [track_a, track_b] }
    let(:inbox) { double }

    it "posts an array of tracks to a user's inbox" do
      expect(api).to receive(:sp_inbox_post_tracks) do |ptr, username, buffer, buffer_size, message, ptr_callback, userdata|
        expect(ptr).to eq(session)
        expect(username).to eq("burgestrand")
        expect(buffer.read_array_of_pointer(buffer_size)).to eq(tracks)
        expect(message).to eq("You must listen to these!")
        expect(ptr_callback).to eq(callback)
        expect(userdata).to eq(:userdata)
        inbox
      end

      expect(api.inbox_post_tracks(session, "burgestrand", tracks, "You must listen to these!", callback, :userdata)).to eq(inbox)
    end

    it "casts a single track to an array" do
      expect(api).to receive(:sp_inbox_post_tracks) do |ptr, username, buffer, buffer_size, message, ptr_callback, userdata|
        expect(buffer.read_array_of_pointer(1)).to eq([track_a])
        expect(buffer_size).to eq(1)
        inbox
      end

      expect(api.inbox_post_tracks(session, "burgestrand", track_a, "You must listen to these!", callback, :userdata)).to eq(inbox)
    end
  end
end
