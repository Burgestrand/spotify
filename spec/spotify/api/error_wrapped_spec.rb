describe "Error wrapped functions" do
  wrapped_methods = $attached_methods.find_all { |meth, info| :error == info[:returns] }
  wrapped_methods.each do |meth, info|
    specify "#{meth} raises an error when the call fails" do
      # forgetting meth.to_sym actually raises a system stack error?!
      api.should_receive(meth.to_sym).and_return(:bad_application_key)
      expect { Spotify::API.new.public_send("#{meth}!") }.to raise_error(Spotify::Error, /BAD_APPLICATION_KEY/)
    end
  end
end
