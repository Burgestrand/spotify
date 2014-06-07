describe Spotify::API do
  describe ".platform" do
    it "prints a warning containing the OS if platform unknown" do
      suppress = true
      _, err = spy_output(suppress) do
        stub_const("FFI::Platform::OS", "LAWL")
        Spotify.platform
      end

      err.should match "unknown platform"
      err.should match "LAWL"
    end
  end
end
