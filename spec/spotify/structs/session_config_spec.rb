describe SpotifyAPI::SessionConfig do
  let(:config) { SpotifyAPI::SessionConfig.new }

  it "allows SessionCallbacks as a member value (by reference)" do
    config[:callbacks] = SpotifyAPI::SessionCallbacks.new
    config[:callbacks].should be_a SpotifyAPI::SessionCallbacks
  end

  it "automatically sets application key size when setting application key from string" do
    config[:application_key] = "h\x00e\x00y"

    config[:application_key_size].should eq 5
    config[:application_key].read_string(5).should eq "h\x00e\x00y"
  end

  it "does not automatically set application key size when setting application key from pointer" do
    expect { config[:application_key] = FFI::MemoryPointer.from_string("yay") }
      .to_not change { config[:application_key_size] }
  end
end
