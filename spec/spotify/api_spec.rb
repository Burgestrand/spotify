describe Spotify::API do
  describe ".attach_function" do
    it "is a retaining class if the method is not creating" do
      begin
        Spotify::API.attach_function :whatever, [], Spotify::User
      rescue FFI::NotFoundError
        # expected, this method does not exist
      end

      expect($attached_methods["whatever"][:returns]).to eq Spotify::User.retaining_class
    end

    it "is a non-retaining class if the method is creating" do
      begin
        Spotify::API.attach_function :whatever_create, [], Spotify::User
      rescue FFI::NotFoundError
        # expected, this method does not exist
      end

      expect($attached_methods["whatever_create"][:returns]).to be Spotify::User
      expect($attached_methods["whatever_create"][:returns]).not_to be Spotify::User.retaining_class
    end
  end
end
