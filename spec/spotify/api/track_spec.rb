describe "Spotify::API" do
  describe "#track_set_starred" do
    let(:session) { double }
    let(:track_a) { FFI::MemoryPointer.new(:pointer) }
    let(:track_b) { FFI::MemoryPointer.new(:pointer) }
    let(:tracks) { [track_a, track_b] }

    it "changes the starred state of the given tracks" do
      api.should_receive(:sp_track_set_starred) do |ptr, buffer, buffer_size, starred|
        ptr.should eq(session)
        buffer.read_array_of_pointer(buffer_size).should eq(tracks)
        starred.should eq(true)
        :ok
      end

      api.track_set_starred(session, tracks, true).should eq(:ok)
    end

    it "automatically casts the second parameter to an array" do
      api.should_receive(:sp_track_set_starred) do |ptr, buffer, buffer_size, starred|
        buffer.read_array_of_pointer(1).should eq([track_a])
        buffer_size.should eq(1)
        :ok
      end

      api.track_set_starred(session, track_a, true).should eq(:ok)
    end
  end
end
