describe "Spotify::API" do
  let(:container) { double }

  describe "#playlistcontainer_playlist_folder_name" do
    let(:index) { 0 }

    it "returns the folder name" do
      api.should_receive(:sp_playlistcontainer_playlist_folder_name) do |ptr, index, name_pointer, name_pointer_size|
        ptr.should eq(container)
        name_pointer.write_bytes("Summer Playlists")
        :ok
      end

      folder_name = api.playlistcontainer_playlist_folder_name(container, index)
      folder_name.should eq "Summer Playlists"
      folder_name.encoding.should eq(Encoding::UTF_8)
    end

    it "returns nil if out of range" do
      api.should_receive(:sp_playlistcontainer_playlist_folder_name) do |ptr, index, name_pointer, name_pointer_size|
        :error_index_out_of_range
      end

      api.playlistcontainer_playlist_folder_name(container, index).should be_nil
    end

    it "returns nil if not a folder" do
      api.should_receive(:sp_playlistcontainer_playlist_folder_name) do |ptr, index, name_pointer, name_pointer_size|
        name_pointer.write_bytes("")
        :ok
      end

      api.playlistcontainer_playlist_folder_name(container, index).should be_nil
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
      Spotify::Track.retaining_class.should_receive(:from_native).twice do |pointer, context|
        pointer.read_int
      end

      api.should_receive(:sp_playlistcontainer_get_unseen_tracks).twice do |ptr, ptr_playlist, tracks_buffer, tracks_buffer_size|
        ptr.should eq(container)
        ptr_playlist.should eq(playlist)
        if tracks_buffer
          tracks_buffer.write_array_of_pointer([track_a, track_b])
          tracks_buffer_size.should eq(2)
        end
        2
      end

      api.playlistcontainer_get_unseen_tracks(container, playlist).should eq([1337, 7331])
    end

    it "returns an empty array when there are no unseen tracks" do
      api.should_receive(:sp_playlistcontainer_get_unseen_tracks) do |ptr, playlist, tracks_buffer, tracks_buffer_size|
        0
      end

      api.playlistcontainer_get_unseen_tracks(container, playlist).should be_empty
    end

    it "returns an empty array on failure" do
      api.should_receive(:sp_playlistcontainer_get_unseen_tracks) do |ptr, playlist, tracks_buffer, tracks_buffer_size|
        -1
      end

      api.playlistcontainer_get_unseen_tracks(container, playlist).should be_empty
    end
  end
end
