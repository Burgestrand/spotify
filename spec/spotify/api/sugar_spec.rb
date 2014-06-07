describe "Spotify::API" do
  describe "#image_data" do
    let(:image) { double }

    it "reads the raw image data" do
      api.should_receive(:sp_image_data) do |img, img_size_pointer|
        img.should eq(image)
        img_size_pointer.should be_a(FFI::Buffer)
        img_size_pointer.size.should eq(FFI.find_type(:size_t).size)

        img_size_pointer.write_size_t(8)
        FFI::MemoryPointer.from_string("image data")
      end

      api.image_data(image).should eq "image da"
    end

    it "is nil if image data is null" do
      api.should_receive(:sp_image_data) do |img, img_size_pointer|
        FFI::Pointer::NULL
      end

      api.image_data(image).should be_nil
    end

    it "is nil if image data size is 0" do
      api.should_receive(:sp_image_data) do |img, img_size_pointer|
        img_size_pointer.write_size_t(0)
        FFI::MemoryPointer.from_string("image data")
      end

      api.image_data(image).should be_nil
    end
  end

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

  describe "#playlist_get_image" do
    let(:playlist) { double }
    let(:image_id) { "v\xE5\xAA\xD3F\xF8\xEE4G\xA1.D\x9C\x85 \xC5\xFD\x80]\x99".b }

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

  describe "#process_events" do
    let(:session) { double }

    it "returns time until session_process_events should be called again" do
      api.should_receive(:sp_session_process_events) do |ptr, timeout_pointer|
        ptr.should eq(session)
        timeout_pointer.write_int(1337)
        :ok
      end

      api.session_process_events(session).should eq(1337)
    end
  end

  describe "#session_remembered_user" do
    let(:session) { double }

    it "returns the name of the remembered user" do
      api.should_receive(:sp_session_remembered_user).twice do |ptr, string_pointer, string_pointer_size|
        ptr.should eq(session)
        string_pointer.write_bytes("BurgeX") if string_pointer
        5
      end

      api.session_remembered_user(session).should eq("Burge")
    end

    it "returns nil if there is no remembered user" do
      api.should_receive(:sp_session_remembered_user) do |ptr, string_pointer, string_pointer_size|
        -1
      end

      api.session_remembered_user(session).should be_nil
    end
  end

  describe "#session_is_scrobbling" do
    let(:session) { double }

    it "returns the scrobbling state" do
      api.should_receive(:sp_session_is_scrobbling) do |ptr, social_provider, state_pointer|
        ptr.should eq(session)
        social_provider.should eq(:spotify)
        state_pointer.write_int(3)
        :ok
      end

      api.session_is_scrobbling(session, :spotify).should eq(:global_enabled)
    end
  end
end
