describe SpotifyAPI::Subscribers do
  it "should create the subscribers array using count" do
    # Memory looks like this:
    #
    # 00 00 00 00 <- count of subscribers
    # 00 00 00 00 <- pointer to subscriber 1
    # …… …… …… ……
    # 00 00 00 00 <- pointer to subscriber n
    real_struct = SpotifyAPI::Subscribers.new(2)
    real_struct[:count] = 2
    real_struct[:subscribers][0] = FFI::MemoryPointer.from_string("a")
    real_struct[:subscribers][1] = FFI::MemoryPointer.from_string("bb")

    struct = SpotifyAPI::Subscribers.new(real_struct.pointer)
    struct[:count].should eq 2
    struct[:subscribers].size.should eq 2
    struct[:subscribers][0].read_string.should eq "a"
    struct[:subscribers][1].read_string.should eq "bb"
    expect { struct[:subscribers][2] }.to raise_error(IndexError)
  end


  it "should not fail given an empty subscribers struct" do
    subscribers = FFI::MemoryPointer.new(:uint)
    subscribers.write_uint(0)

    subject = SpotifyAPI::Subscribers.new(subscribers)
    subject[:count].should eq 0
    expect { subject[:subscribers] }.to raise_error(ArgumentError)
  end
end
