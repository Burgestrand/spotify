describe Spotify::CountryCode do
  let(:context) { nil }
  subject(:type) { Spotify::API.find_type(Spotify::CountryCode) }

  describe ".from_native" do
    it "decodes a country code" do
      expect(type.from_native(21317, context)).to eq "SE"
    end
  end

  describe ".to_native" do
    it "encodes a country code" do
      expect(type.to_native("SE", context)).to eq 21317
    end
  end
end
