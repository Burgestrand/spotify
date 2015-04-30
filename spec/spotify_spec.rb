describe Spotify do
  describe "VERSION" do
    it "is defined" do
      expect(defined?(Spotify::VERSION)).to eq "constant"
    end

    it "is the same version as in api.h" do
      spotify_version = API_H_SRC.match(/#define\s+SPOTIFY_API_VERSION\s+(\d+)/)[1]
      expect(Spotify::API_VERSION.to_i).to eq spotify_version.to_i
    end
  end

  describe "proxying" do
    it "responds to the spotify methods" do
      expect(Spotify).to respond_to :error_message
    end

    it "allows creating proxy methods" do
      expect(api).to receive(:error_message).and_return("Some error")
      expect(Spotify.method(:error_message).call).to eq "Some error"
    end
  end

  describe ".log" do
    it "print nothing if not debugging" do
      out, err = spy_output do
        old_debug, $DEBUG = $DEBUG, false
        Spotify.log "They see me loggin'"
        $DEBUG = old_debug
      end
      expect(out).to be_empty
      expect(err).to be_empty
    end

    it "prints output and path if debugging" do
      suppress = true
      out, err = spy_output(suppress) do
        old_debug, $DEBUG = $DEBUG, true
        Spotify.log "Testin' Spotify log"
        $DEBUG = old_debug
      end

      expect(out).to match "Testin' Spotify log"
      expect(out).to match "spec/spotify_spec.rb"

      expect(err).to be_empty
    end
  end

  describe ".try" do
    it "raises an error when the result is not OK" do
      expect(api).to receive(:error_example).and_return(Spotify::APIError.from_native(5, nil))
      expect { Spotify.try(:error_example) }.to raise_error(Spotify::BadApplicationKeyError, /Invalid application key/)
    end

    it "does not raise an error when the result is OK" do
      expect(api).to receive(:error_example).and_return(nil)
      expect(Spotify.try(:error_example)).to eq nil
    end

    it "does not raise an error when the result is not an error-type" do
      result = Object.new
      expect(api).to receive(:error_example).and_return(result)
      expect(Spotify.try(:error_example)).to eq result
    end

    it "does not raise an error when the resource is loading" do
      expect(api).to receive(:error_example).and_return(Spotify::APIError.from_native(17, nil))
      error = Spotify.try(:error_example)
      expect(error).to be_a(Spotify::IsLoadingError)
      expect(error.message).to match /Resource not loaded yet/
    end
  end
end
