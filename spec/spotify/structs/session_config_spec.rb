describe Spotify::SessionConfig do
  let(:config) { Spotify::SessionConfig.new }

  let(:options) do
    {
      :api_version => 1337,
      :tracefile => nil,
      :cache_location => "rspec 2",
      :settings_location => "tmp/",
      :user_agent => "Hallon",
      :compress_playlists => true,
    }
  end

  it "accepts a hash for initialization" do
    config = Spotify::SessionConfig.new(options)
    options.each_pair { |key, value| config[key].should eq value }
  end

  it "allows SessionCallbacks as a member value (by reference)" do
    config[:callbacks] = Spotify::SessionCallbacks.new
    config[:callbacks].should be_a Spotify::SessionCallbacks
  end

  it "allows setting and getting string pointer values" do
    expect { config[:cache_location] = "rspec 2" }
      .to change { config[:cache_location] }.to("rspec 2")
  end
end
