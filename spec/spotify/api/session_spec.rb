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
      expect(api).to receive(:sp_session_create) do |struct_config, ptr_session|
        expect(struct_config).to be_a(Spotify::SessionConfig)
        expect(struct_config[:user_agent]).to eq("This is a test")
        expect(struct_config[:callbacks]).to be_a(Spotify::SessionCallbacks)
        ptr_session.write_pointer(session_pointer)
        :ok
      end

      error, session = api.session_create(config)
      expect(error).to be_nil
      expect(session).to be_a(Spotify::Session)
      expect(session.address).to eq(session_pointer.address)
    end

    it "returns the error without session on failure" do
      expect(api).to receive(:sp_session_create) do |struct_config, ptr_session|
        :bad_api_version
      end

      error, session = api.session_create(config)
      expect(error).to eq(:bad_api_version)
      expect(session).to be_nil
    end
  end

  describe "#session_process_events" do
    it "returns time until session_process_events should be called again" do
      expect(api).to receive(:sp_session_process_events) do |ptr, timeout_pointer|
        expect(ptr).to eq(session)
        timeout_pointer.write_int(1337)
        :ok
      end

      expect(api.session_process_events(session)).to eq(1337)
    end
  end

  describe "#session_remembered_user" do
    it "returns the name of the remembered user" do
      expect(api).to receive(:sp_session_remembered_user).twice do |ptr, string_pointer, string_pointer_size|
        expect(ptr).to eq(session)
        string_pointer.write_bytes("BurgeX") if string_pointer
        5
      end

      expect(api.session_remembered_user(session)).to eq("Burge")
    end

    it "returns nil if there is no remembered user" do
      expect(api).to receive(:sp_session_remembered_user) do |ptr, string_pointer, string_pointer_size|
        -1
      end

      expect(api.session_remembered_user(session)).to be_nil
    end
  end

  describe "#session_is_scrobbling" do
    it "returns the scrobbling state" do
      expect(api).to receive(:sp_session_is_scrobbling) do |ptr, social_provider, state_pointer|
        expect(ptr).to eq(session)
        expect(social_provider).to eq(:spotify)
        state_pointer.write_int(3)
        :ok
      end

      expect(api.session_is_scrobbling(session, :spotify)).to eq(:global_enabled)
    end
  end

  describe "#session_is_scrobbling_possible" do
    it "returns true if scrobbling is possible" do
      expect(api).to receive(:sp_session_is_scrobbling_possible) do |ptr, social_provider, buffer_out|
        expect(ptr).to eq(session)
        expect(social_provider).to eq(:spotify)
        buffer_out.write_char(1)
        :ok
      end

      expect(api.session_is_scrobbling_possible(session, :spotify)).to eq(true)
    end
  end
end
