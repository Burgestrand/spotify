describe "Spotify::API" do
  let(:container) { double }

  describe "#playlistcontainer_playlist_folder_name" do
    let(:index) { 0 }

    it "returns the folder name" do
      expect(api).to receive(:sp_playlistcontainer_playlist_folder_name) do |ptr, index, name_pointer, name_pointer_size|
        expect(ptr).to eq(container)
        name_pointer.write_bytes("Summer Playlists\x00")
        :ok
      end

      folder_name = api.playlistcontainer_playlist_folder_name(container, index)
      expect(folder_name).to eq "Summer Playlists"
      expect(folder_name.encoding).to eq(Encoding::UTF_8)
    end

    it "returns nil if out of range" do
      expect(api).to receive(:sp_playlistcontainer_playlist_folder_name) do |ptr, index, name_pointer, name_pointer_size|
        :error_index_out_of_range
      end

      expect(api.playlistcontainer_playlist_folder_name(container, index)).to be_nil
    end

    it "returns nil if not a folder" do
      expect(api).to receive(:sp_playlistcontainer_playlist_folder_name) do |ptr, index, name_pointer, name_pointer_size|
        name_pointer.write_bytes("\x00")
        :ok
      end

      expect(api.playlistcontainer_playlist_folder_name(container, index)).to be_nil
    end
  end

  describe "#playlistcontainer_get_unseen_tracks" do
    def track(id)
      pointer = FFI::MemoryPointer.new(:int)
      pointer.write_int(id.to_i)
      pointer
    end

    let(:playlist) { double }
    let(:track_a) { track(1337) }
    let(:track_b) { track(7331) }

    it "returns an array of unseen tracks" do
      expect(Spotify::Track.retaining_class).to receive(:from_native).twice do |pointer, context|
        pointer.read_int
      end

      expect(api).to receive(:sp_playlistcontainer_get_unseen_tracks).twice do |ptr, ptr_playlist, tracks_buffer, tracks_buffer_size|
        expect(ptr).to eq(container)
        expect(ptr_playlist).to eq(playlist)
        if tracks_buffer
          tracks_buffer.write_array_of_pointer([track_a, track_b])
          expect(tracks_buffer_size).to eq(2)
        end
        2
      end

      expect(api.playlistcontainer_get_unseen_tracks(container, playlist)).to eq([1337, 7331])
    end

    it "returns an empty array when there are no unseen tracks" do
      expect(api).to receive(:sp_playlistcontainer_get_unseen_tracks) do |ptr, playlist, tracks_buffer, tracks_buffer_size|
        0
      end

      expect(api.playlistcontainer_get_unseen_tracks(container, playlist)).to be_empty
    end

    it "returns an empty array on failure" do
      expect(api).to receive(:sp_playlistcontainer_get_unseen_tracks) do |ptr, playlist, tracks_buffer, tracks_buffer_size|
        -1
      end

      expect(api.playlistcontainer_get_unseen_tracks(container, playlist)).to be_empty
    end
  end
end
