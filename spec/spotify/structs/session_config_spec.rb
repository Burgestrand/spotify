describe Spotify::SessionConfig do
  let(:config) { Spotify::SessionConfig.new }

  it "allows SessionCallbacks as a member value (by reference)" do
    config[:callbacks] = Spotify::SessionCallbacks.new
    expect(config[:callbacks]).to be_a Spotify::SessionCallbacks
  end

  it "automatically sets application key size when setting application key from string" do
    config[:application_key] = "h\x00e\x00y"

    expect(config[:application_key_size]).to eq 5
    expect(config[:application_key].read_string(5)).to eq "h\x00e\x00y"
  end

  it "does not support setting application key with a pointer" do
    expect { config[:application_key] = FFI::MemoryPointer.from_string("yay") }
      .to raise_error(NoMethodError, /to_str/)
  end
end
