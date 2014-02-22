describe Spotify::CountryCode do
  let(:context) { nil }
  subject(:type) { Spotify::API.find_type(Spotify::CountryCode) }

  describe ".from_native" do
    it "decodes a country code" do
      type.from_native(21317, context).should eq "SE"
    end
  end

  describe ".to_native" do
    it "encodes a country code" do
      type.to_native("SE", context).should eq 21317
    end
  end
end
