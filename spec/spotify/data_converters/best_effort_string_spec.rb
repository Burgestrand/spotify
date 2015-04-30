# encoding: utf-8
describe Spotify::BestEffortString do
  describe "#to_native" do
    it "simply reads a null-terminated string" do
      source = "hello wörld"
      string = Spotify::BestEffortString.to_native(source, nil)
      expect(string).to eq "hello wörld".force_encoding(Encoding::BINARY)
    end

    it "cuts the string at the first encountered NULL-byte" do
      source = "hello\x00wörld".force_encoding(Encoding::BINARY)
      string = Spotify::BestEffortString.to_native(source, nil)
      expect(string).to eq "hello".force_encoding(Encoding::BINARY)
    end

    it "treats empty string as empty string, and not null" do
      source = ""
      string = Spotify::BestEffortString.to_native(source, nil)
      expect(string).to eq "".force_encoding(Encoding::BINARY)
    end
  end
end
