describe "Error wrapped functions" do
  wrapped_methods = Spotify.attached_methods.find_all { |meth, info| info[:returns] == :error }
  wrapped_methods.each do |meth, info|
    specify "#{meth} raises an error when the call fails" do
      Spotify.should_receive(meth).and_return(:bad_application_key)
      expect { Spotify.send("#{meth}!") }.to raise_error(Spotify::Error, /BAD_APPLICATION_KEY/)
    end
  end
end
