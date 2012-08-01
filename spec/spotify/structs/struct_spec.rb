describe SpotifyAPI::Struct do
  let(:klass) do
    Class.new(SpotifyAPI::Struct) do
      layout :api_version => :int,
             :cache_location => SpotifyAPI::NULString,
             :user_agent => SpotifyAPI::NULString,
             :compress_playlists => :bool
    end
  end

  let(:options) do
    {
      :api_version => 1,
      :cache_location => "Yay",
      :user_agent => nil,
      :compress_playlists => false
    }
  end

  it "allows initializing the struct with a hash" do
    struct = klass.new(options)
    options.each_pair { |key, value| struct[key].should eq value }
  end

  it "allows initializing the struct with a pointer" do
    original = klass.new(options)
    struct = klass.new(original.pointer)
    options.each_pair { |key, value| struct[key].should eq value }
  end

  it "allows initializing the struct with nothing" do
    expect { klass.new }.to_not raise_error
  end
end
