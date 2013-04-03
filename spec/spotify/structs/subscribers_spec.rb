describe Spotify::Subscribers do
  it "should create the subscribers array using count" do
    # Memory looks like this:
    #
    # 00 00 00 00 <- count of subscribers
    # 00 00 00 00 <- pointer to subscriber 1
    # …… …… …… ……
    # 00 00 00 00 <- pointer to subscriber n
    real_struct = Spotify::Subscribers.new(2)
    real_struct[:count] = 2
    real_struct[:subscribers][0] = FFI::MemoryPointer.from_string("a")
    real_struct[:subscribers][1] = FFI::MemoryPointer.from_string("bb")

    struct = Spotify::Subscribers.new(real_struct.pointer)
    struct[:count].should eq 2
    struct[:subscribers].size.should eq 2
    struct[:subscribers][0].read_string.should eq "a"
    struct[:subscribers][1].read_string.should eq "bb"
    expect { struct[:subscribers][2] }.to raise_error(IndexError)
  end

  it "should not fail given an empty subscribers struct" do
    subscribers = FFI::MemoryPointer.new(:uint)
    subscribers.write_uint(0)

    subject = Spotify::Subscribers.new(subscribers)
    subject[:count].should eq 0
    subject[:subscribers].size.should eq 0
  end

  it "should not fail given a null pointer" do
    subject = Spotify::Subscribers.new(FFI::Pointer::NULL)
    subject.should be_null
    expect { subject[:count] }.to raise_error(FFI::NullPointerError)
    subject[:subscribers].size.should eq 0
  end
end
