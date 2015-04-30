describe Spotify::APIError do
  let(:context) { nil }

  describe ".from_native" do
    it "returns an error of the correct class" do
      error = Spotify::APIError.from_native(15, context)
      expect(error).to be_a Spotify::UserNeedsPremiumError
    end

    it "returns nil if not an error" do
      expect(Spotify::APIError.from_native(0, context)).to be_nil
    end

    it "raises an error if not a valid error code" do
      expect { Spotify::APIError.from_native(1337, context) }
        .to raise_error(ArgumentError, /unknown error code/)
    end
  end

  describe ".to_i" do
    it "returns the error code" do
      expect(Spotify::APIError.to_i).to be_nil
      expect(Spotify::UserNeedsPremiumError.to_i).to eq(15)
    end
  end

  describe "#message" do
    it "is a formatted message with an explanation of the error" do
      error = Spotify::UserNeedsPremiumError.new
      expect(error.message).to match /Needs a premium account/
      expect(error.message).to match /15/
    end

    it "can be overridden if necessary" do
      error = Spotify::UserNeedsPremiumError.new("hoola hoop")
      expect(error.message).to eq "hoola hoop"
    end
  end

  describe "API mapping" do
    sp_error = API_H_XML.enumerations.each { |enum| break enum if enum.name == "sp_error" }
    sp_error.values.each do |value|
      next if value.name =~ /sp_error_ok/i
      class_name = value.name.downcase.sub(/^sp_error/, "").gsub(/(_|^)(\w)/) { $2.upcase }
      class_name << "Error" unless class_name =~ /Error/

      describe class_name do
        it "should have the error code number" do
          constant = Spotify.constants.grep(/#{class_name}/i)[0]
          expect(Spotify.const_get(constant).to_i).to eq(value["init"].to_i)
        end
      end
    end
  end
end
