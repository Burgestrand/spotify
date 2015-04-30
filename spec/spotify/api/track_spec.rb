describe "Spotify::API" do
  describe "#track_set_starred" do
    let(:session) { double }
    let(:track_a) { FFI::MemoryPointer.new(:pointer) }
    let(:track_b) { FFI::MemoryPointer.new(:pointer) }
    let(:tracks) { [track_a, track_b] }

    it "changes the starred state of the given tracks" do
      expect(api).to receive(:sp_track_set_starred) do |ptr, buffer, buffer_size, starred|
        expect(ptr).to eq(session)
        expect(buffer.read_array_of_pointer(buffer_size)).to eq(tracks)
        expect(starred).to eq(true)
        :ok
      end

      expect(api.track_set_starred(session, tracks, true)).to eq(:ok)
    end

    it "automatically casts the second parameter to an array" do
      expect(api).to receive(:sp_track_set_starred) do |ptr, buffer, buffer_size, starred|
        expect(buffer.read_array_of_pointer(1)).to eq([track_a])
        expect(buffer_size).to eq(1)
        :ok
      end

      expect(api.track_set_starred(session, track_a, true)).to eq(:ok)
    end
  end
end
