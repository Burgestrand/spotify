describe Spotify::APIError do
  let(:context) { nil }

  describe ".from_native" do
    it "returns an error of the correct class" do
      error = Spotify::APIError.from_native(15, context)
      error.should be_a Spotify::UserNeedsPremiumError
    end

    it "returns nil if not an error" do
      Spotify::APIError.from_native(0, context).should be_nil
    end

    it "raises an error if not a valid error code" do
      expect { Spotify::APIError.from_native(1337, context) }
        .to raise_error(ArgumentError, /unknown error code/)
    end
  end

  describe ".to_i" do
    it "returns the error code" do
      Spotify::APIError.to_i.should be_nil
      Spotify::UserNeedsPremiumError.to_i.should eq(15)
    end
  end

  describe "#message" do
    it "is a formatted message with an explanation of the error" do
      error = Spotify::UserNeedsPremiumError.new
      error.message.should match /Needs a premium account/
      error.message.should match /15/
    end

    it "can be overridden if necessary" do
      error = Spotify::UserNeedsPremiumError.new("hoola hoop")
      error.message.should eq "hoola hoop"
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
          Spotify.const_get(constant).to_i.should eq(value["init"].to_i)
        end
      end
    end
  end
end
