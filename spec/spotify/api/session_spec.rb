describe "Spotify::API" do
  let(:session) { double }

  describe "#session_create" do
    let(:config) do
      {
        user_agent: "This is a test",
        callbacks: Spotify::SessionCallbacks.new(music_delivery: proc {})
      }
    end

    let(:session_pointer) { FFI::MemoryPointer.new(:pointer) }

    it "creates a session with the given configuration" do
      api.should_receive(:sp_session_create) do |struct_config, ptr_session|
        struct_config.should be_a(Spotify::SessionConfig)
        struct_config[:user_agent].should eq("This is a test")
        struct_config[:callbacks].should be_a(Spotify::SessionCallbacks)
        ptr_session.write_pointer(session_pointer)
        :ok
      end

      error, session = api.session_create(config)
      error.should be_nil
      session.should be_a(Spotify::Session)
      session.address.should eq(session_pointer.address)
    end

    it "returns the error without session on failure" do
      api.should_receive(:sp_session_create) do |struct_config, ptr_session|
        :bad_api_version
      end

      error, session = api.session_create(config)
      error.should eq(:bad_api_version)
      session.should be_nil
    end
  end

  describe "#session_process_events" do
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

  describe "#session_is_scrobbling_possible" do
    it "returns true if scrobbling is possible" do
      api.should_receive(:sp_session_is_scrobbling_possible) do |ptr, social_provider, buffer_out|
        ptr.should eq(session)
        social_provider.should eq(:spotify)
        buffer_out.write_char(1)
        :ok
      end

      api.session_is_scrobbling_possible(session, :spotify).should eq(true)
    end
  end
end
