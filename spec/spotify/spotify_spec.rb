describe Spotify do
  describe "VERSION" do
    it "is defined" do
      defined?(Spotify::VERSION).should eq "constant"
    end

    it "is the same version as in api.h" do
      spotify_version = API_H_SRC.match(/#define\s+SPOTIFY_API_VERSION\s+(\d+)/)[1]
      Spotify::API_VERSION.to_i.should eq spotify_version.to_i
    end
  end

  describe "proxying" do
    it "responds to the spotify methods" do
      Spotify.should respond_to :error_message
    end

    it "always dispatches calls safely" do
      api.should_receive(:error_example).and_raise(Spotify::Error)
      expect { Spotify.error_example }.to raise_error(Spotify::Error)
      Spotify.should be_alive
    end
  end

  describe ".try" do
    it "raises an error when the result is not OK" do
      api.should_receive(:error_example).and_return(:bad_application_key)
      expect { Spotify.try(:error_example) }.to raise_error(Spotify::Error, /BAD_APPLICATION_KEY/)
    end

    it "does not raise an error when the result is OK" do
      api.should_receive(:error_example).and_return(:ok)
      Spotify.try(:error_example).should eq :ok
    end

    it "does not raise an error when the result is not an error-type" do
      result = Object.new
      api.should_receive(:error_example).and_return(result)
      Spotify.try(:error_example).should eq result
    end
  end

  describe ".enum_value!" do
    it "raises an error if given an invalid enum value" do
      expect { Spotify.enum_value!(:moo, "error value") }.to raise_error(ArgumentError)
    end

    it "gives back the enum value for that enum" do
      Spotify.enum_value!(:ok, "error value").should eq 0
    end
  end

  describe ".attach_function" do
    it "is a retaining class if the method is not creating" do
      begin
        Spotify::API.attach_function :whatever, [], Spotify::User
      rescue FFI::NotFoundError
        # expected, this method does not exist
      end

      $attached_methods["whatever"][:returns].should eq Spotify::User.retaining_class
    end

    it "is a non-retaining class if the method is creating" do
      begin
        Spotify::API.attach_function :whatever_create, [], Spotify::User
      rescue FFI::NotFoundError
        # expected, this method does not exist
      end

      $attached_methods["whatever_create"][:returns].should be Spotify::User
      $attached_methods["whatever_create"][:returns].should_not be Spotify::User.retaining_class
    end
  end
end
