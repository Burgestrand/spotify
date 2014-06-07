describe "Spotify::API" do
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

  describe "#session_is_scrobbling_possible" do
    let(:session) { double }

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
