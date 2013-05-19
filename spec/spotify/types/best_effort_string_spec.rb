# encoding: utf-8
describe Spotify::BestEffortString do
  describe "#to_native" do
    it "simply reads a null-terminated string" do
      string = Spotify::BestEffortString.to_native("hello world", nil)
      string.should eq "hello world"
    end

    it "cuts the string at the first encountered NULL-byte" do
      string = Spotify::BestEffortString.to_native("hello\x00world", nil)
      string.should eq "hello"
    end

    it "treats empty string as empty string, and not null" do
      string = Spotify::BestEffortString.to_native("", nil)
      string.should eq ""
    end
  end
end
