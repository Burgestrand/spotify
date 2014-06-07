describe Spotify::API do
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
