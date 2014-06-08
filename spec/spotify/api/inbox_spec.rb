describe "Spotify::API" do
  describe "#inbox_post_tracks" do
    let(:session) { double }
    let(:callback) { lambda {} }
    let(:track_a) { FFI::MemoryPointer.new(:pointer) }
    let(:track_b) { FFI::MemoryPointer.new(:pointer) }
    let(:tracks) { [track_a, track_b] }
    let(:inbox) { double }

    it "posts an array of tracks to a user's inbox" do
      api.should_receive(:sp_inbox_post_tracks) do |ptr, username, buffer, buffer_size, message, ptr_callback, userdata|
        ptr.should eq(session)
        username.should eq("burgestrand")
        buffer.read_array_of_pointer(buffer_size).should eq(tracks)
        message.should eq("You must listen to these!")
        ptr_callback.should eq(callback)
        userdata.should eq(:userdata)
        inbox
      end

      api.inbox_post_tracks(session, "burgestrand", tracks, "You must listen to these!", callback, :userdata).should eq(inbox)
    end

    it "casts a single track to an array" do
      api.should_receive(:sp_inbox_post_tracks) do |ptr, username, buffer, buffer_size, message, ptr_callback, userdata|
        buffer.read_array_of_pointer(1).should eq([track_a])
        buffer_size.should eq(1)
        inbox
      end

      api.inbox_post_tracks(session, "burgestrand", track_a, "You must listen to these!", callback, :userdata).should eq(inbox)
    end
  end
end
