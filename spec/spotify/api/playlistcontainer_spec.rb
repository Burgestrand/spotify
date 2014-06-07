describe "Spotify::API" do
  describe "#playlistcontainer_playlist_folder_name" do
    let(:container) { double }
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
end
