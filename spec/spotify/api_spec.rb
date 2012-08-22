describe Spotify::API do
  describe ".platform" do
    it "prints a warning containing the OS if platform unknown" do
      old_platform = FFI::Platform::OS.dup
      $stderr, old_stderr = StringIO.new, $stderr

      begin
        FFI::Platform::OS.replace "LAWL"
        Spotify.platform
        $stderr.rewind
        $stderr.read.should include "LAWL"
      ensure
        $stderr = old_stderr
        FFI::Platform::OS.replace(old_platform)
      end
    end
  end
end
