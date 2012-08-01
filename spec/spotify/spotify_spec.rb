describe SpotifyAPI do
  describe "VERSION" do
    it "is defined" do
      defined?(SpotifyAPI::VERSION).should eq "constant"
    end

    it "is the same version as in api.h" do
      spotify_version = API_H_SRC.match(/#define\s+SPOTIFY_API_VERSION\s+(\d+)/)[1]
      SpotifyAPI::API_VERSION.to_i.should eq spotify_version.to_i
    end
  end

  describe ".enum_value!" do
    it "raises an error if given an invalid enum value" do
      expect { SpotifyAPI.enum_value!(:moo, "error value") }.to raise_error(ArgumentError)
    end

    it "gives back the enum value for that enum" do
      SpotifyAPI.enum_value!(:ok, "error value").should eq 0
    end
  end

  describe ".attach_function" do
    it "is a retaining class if the method is not creating" do
      begin
        SpotifyAPI.attach_function :whatever, [], SpotifyAPI::User
      rescue FFI::NotFoundError
        # expected, this method does not exist
      end

      SpotifyAPI.attached_methods["whatever"][:returns].should eq SpotifyAPI::User.retaining_class
    end

    it "is a non-retaining class if the method is creating" do
      begin
        SpotifyAPI.attach_function :whatever_create, [], SpotifyAPI::User
      rescue FFI::NotFoundError
        # expected, this method does not exist
      end

      SpotifyAPI.attached_methods["whatever_create"][:returns].should be SpotifyAPI::User
      SpotifyAPI.attached_methods["whatever_create"][:returns].should_not be SpotifyAPI::User.retaining_class
    end
  end
end
