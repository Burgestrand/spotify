describe "Spotify::API" do
  let(:playlist) { double }

  describe "#playlist_get_image" do
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

  describe "#playlist_add_tracks" do
    let(:session) { double }
    let(:track_a) { FFI::MemoryPointer.new(:pointer) }
    let(:track_b) { FFI::MemoryPointer.new(:pointer) }
    let(:tracks) { [track_a, track_b] }

    it "adds an array of tracks to a playlist" do
      api.should_receive(:sp_playlist_add_tracks) do |ptr, buffer, buffer_size, offset, ptr_session|
        ptr.should eq(playlist)
        buffer.read_array_of_pointer(buffer_size).should eq(tracks)
        offset.should eq(2)
        ptr_session.should eq(session)
        :ok
      end

      api.playlist_add_tracks(playlist, tracks, 2, session).should eq(:ok)
    end

    it "casts a single track to an array" do
      api.should_receive(:sp_playlist_add_tracks) do |ptr, buffer, buffer_size, offset, ptr_session|
        buffer.read_array_of_pointer(1).should eq([track_a])
        buffer_size.should eq(1)
        :ok
      end

      api.playlist_add_tracks(playlist, track_a, 2, session).should eq(:ok)
    end
  end

  describe "#playlist_remove_tracks" do
    it "removes tracks from a playlist" do
      api.should_receive(:sp_playlist_remove_tracks) do |ptr, buffer, buffer_size|
        ptr.should eq(playlist)
        buffer.read_array_of_int(buffer_size).should eq([1, 3, 7])
        :ok
      end

      api.playlist_remove_tracks(playlist, [1, 3, 7]).should eq(:ok)
    end

    it "casts a single index to an array" do
      api.should_receive(:sp_playlist_remove_tracks) do |ptr, buffer, buffer_size|
        buffer.read_array_of_int(1).should eq([3])
        buffer_size.should eq(1)
        :ok
      end

      api.playlist_remove_tracks(playlist, 3).should eq(:ok)
    end
  end
end
