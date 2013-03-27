describe Spotify::SessionConfig do
  let(:config) { Spotify::SessionConfig.new }

  it "allows SessionCallbacks as a member value (by reference)" do
    config[:callbacks] = Spotify::SessionCallbacks.new
    config[:callbacks].should be_a Spotify::SessionCallbacks
  end

  it "automatically sets application key size when setting application key from string" do
    config[:application_key] = "h\x00e\x00y"

    config[:application_key_size].should eq 5
    config[:application_key].read_string(5).should eq "h\x00e\x00y"
  end

  it "does not support setting application key with a pointer" do
    expect { config[:application_key] = FFI::MemoryPointer.from_string("yay") }
      .to raise_error(NoMethodError, /to_str/)
  end
end
