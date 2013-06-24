# encoding: utf-8
describe Spotify::BestEffortString do
  describe "#to_native" do
    it "simply reads a null-terminated string" do
      source = "hello wörld"
      string = Spotify::BestEffortString.to_native(source, nil)
      string.should eq "hello wörld".force_encoding("BINARY")
    end

    it "cuts the string at the first encountered NULL-byte" do
      source = "hello\x00wörld".force_encoding("BINARY")
      string = Spotify::BestEffortString.to_native(source, nil)
      string.should eq "hello".force_encoding("BINARY")
    end

    it "treats empty string as empty string, and not null" do
      source = ""
      string = Spotify::BestEffortString.to_native(source, nil)
      string.should eq "".force_encoding("BINARY")
    end
  end
end
