describe Spotify::SessionConfig do
  let(:config) { Spotify::SessionConfig.new }

  it "allows SessionCallbacks as a member value (by reference)" do
    config[:callbacks] = Spotify::SessionCallbacks.new
    config[:callbacks].should be_a Spotify::SessionCallbacks
  end
end
