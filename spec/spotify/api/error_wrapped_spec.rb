describe "Error wrapped functions" do
  wrapped_methods = SpotifyAPI.attached_methods.find_all { |meth, info| :error == info[:returns] }
  wrapped_methods.each do |meth, info|
    specify "#{meth} raises an error when the call fails" do
      SpotifyAPI.should_receive(meth).and_return(:bad_application_key)
      expect { SpotifyAPI.send("#{meth}!") }.to raise_error(SpotifyAPI::Error, /BAD_APPLICATION_KEY/)
    end
  end
end
