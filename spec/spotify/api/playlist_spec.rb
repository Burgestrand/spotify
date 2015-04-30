describe "Spotify::API" do
  let(:playlist) { double }

  describe "#playlist_get_image" do
    let(:image_id) { "v\xE5\xAA\xD3F\xF8\xEE4G\xA1.D\x9C\x85 \xC5\xFD\x80]\x99".force_encoding(Encoding::BINARY) }

    it "returns the image ID if playlist has an image" do
      expect(api).to receive(:sp_playlist_get_image) do |ptr, image_id_pointer|
        expect(ptr).to eq(playlist)
        image_id_pointer.write_bytes(image_id)
        true
      end

      expect(api.playlist_get_image(playlist)).to eq(image_id)
    end

    it "returns nil if playlist has no image" do
      expect(api).to receive(:sp_playlist_get_image) do |ptr, image_id_pointer|
        false
      end

      expect(api.playlist_get_image(playlist)).to be_nil
    end
  end

  describe "#playlist_add_tracks" do
    let(:session) { double }
    let(:track_a) { FFI::MemoryPointer.new(:pointer) }
    let(:track_b) { FFI::MemoryPointer.new(:pointer) }
    let(:tracks) { [track_a, track_b] }

    it "adds an array of tracks to a playlist" do
      expect(api).to receive(:sp_playlist_add_tracks) do |ptr, buffer, buffer_size, offset, ptr_session|
        expect(ptr).to eq(playlist)
        expect(buffer.read_array_of_pointer(buffer_size)).to eq(tracks)
        expect(offset).to eq(2)
        expect(ptr_session).to eq(session)
        :ok
      end

      expect(api.playlist_add_tracks(playlist, tracks, 2, session)).to eq(:ok)
    end

    it "casts a single track to an array" do
      expect(api).to receive(:sp_playlist_add_tracks) do |ptr, buffer, buffer_size, offset, ptr_session|
        expect(buffer.read_array_of_pointer(1)).to eq([track_a])
        expect(buffer_size).to eq(1)
        :ok
      end

      expect(api.playlist_add_tracks(playlist, track_a, 2, session)).to eq(:ok)
    end
  end

  describe "#playlist_remove_tracks" do
    it "removes tracks from a playlist" do
      expect(api).to receive(:sp_playlist_remove_tracks) do |ptr, buffer, buffer_size|
        expect(ptr).to eq(playlist)
        expect(buffer.read_array_of_int(buffer_size)).to eq([1, 3, 7])
        :ok
      end

      expect(api.playlist_remove_tracks(playlist, [1, 3, 7])).to eq(:ok)
    end

    it "casts a single index to an array" do
      expect(api).to receive(:sp_playlist_remove_tracks) do |ptr, buffer, buffer_size|
        expect(buffer.read_array_of_int(1)).to eq([3])
        expect(buffer_size).to eq(1)
        :ok
      end

      expect(api.playlist_remove_tracks(playlist, 3)).to eq(:ok)
    end
  end

  describe "#playlist_reorder_tracks" do
    it "reorders tracks from a playlist" do
      expect(api).to receive(:sp_playlist_reorder_tracks) do |ptr, buffer, buffer_size, index|
        expect(ptr).to eq(playlist)
        expect(buffer.read_array_of_int(buffer_size)).to eq([1, 3, 7])
        expect(index).to eq(3)
        :ok
      end

      expect(api.playlist_reorder_tracks(playlist, [1, 3, 7], 3)).to eq(:ok)
    end

    it "casts a single index to an array" do
      expect(api).to receive(:sp_playlist_reorder_tracks) do |ptr, buffer, buffer_size, index|
        expect(buffer.read_array_of_int(1)).to eq([7])
        expect(buffer_size).to eq(1)
        :ok
      end

      expect(api.playlist_reorder_tracks(playlist, 7, 3)).to eq(:ok)
    end
  end
end
