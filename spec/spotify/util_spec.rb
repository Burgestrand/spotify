describe "Spotify::Util" do
  describe ".enum_value!" do
    it "raises an error if given an invalid enum value" do
      expect { Spotify::Util.enum_value!(:moo, "error value") }.to raise_error(ArgumentError)
    end

    it "gives back the enum value for that enum" do
      expect(Spotify::Util.enum_value!(:no_tracks, "search browse")).to eq 1
    end
  end

  describe ".platform" do
    it "prints a warning containing the OS if platform unknown" do
      suppress = true
      _, err = spy_output(suppress) do
        stub_const("FFI::Platform::OS", "LAWL")
        Spotify::Util.platform
      end

      expect(err).to match "unknown platform"
      expect(err).to match "LAWL"
    end
  end
end
