describe Spotify::Error do
  describe ".explain" do
    it "humanizes a spotify error enum into a string" do
      error_message = Spotify::Error.explain(:user_needs_premium)
      error_message.should match(/15/)
      error_message.should match(/USER_NEEDS_PREMIUM/)
      error_message.should match(/Needs a premium account/)
    end
  end

  describe ".disambiguate" do
    specify "when given an error symbol" do
      Spotify::Error.disambiguate(:user_needs_premium).should eq([15, :user_needs_premium])
    end

    specify "when given an error code" do
      Spotify::Error.disambiguate(15).should eq([15, :user_needs_premium])
    end

    specify "when given a non-error symbol" do
      Spotify::Error.disambiguate(:small).should eq([-1, nil])
    end

    specify "when given a non-error code" do
      Spotify::Error.disambiguate(1337).should eq([-1, nil])
    end

    specify "when given a string" do
      Spotify::Error.disambiguate("This is not an error symbol").should eq([-1, nil])
    end
  end

  describe "#initialize" do
    it "explains the error code as the message" do
      error = Spotify::Error.new(:user_needs_premium)
      error.message.should match(/15/)
      error.message.should match(/USER_NEEDS_PREMIUM/)
      error.message.should match(/Needs a premium account/)
    end

    it "extracts the error code into accessors" do
      error = Spotify::Error.new(:user_needs_premium)
      error.code.should eq(15)
      error.symbol.should eq(:user_needs_premium)
    end

    it "accepts a string" do
      error = Spotify::Error.new("Not an error code")
      error.code.should eq(-1)
      error.symbol.should eq(nil)
      error.message.should eq("Not an error code")
    end
  end
end
