describe Spotify::TypeSafety do
  let(:superklass) do
    Class.new do
      def self.to_native(value, ctx)
        value
      end
    end
  end

  let(:klass) do
    Class.new(superklass) do
      extend Spotify::TypeSafety

      def self.type_class
        self
      end
    end
  end

  describe "#to_native" do
    it "calls to the superclass if value is accepted" do
      value = klass.new
      klass.to_native(value, nil).should eq value
    end

    it "raises a type error if the value is of the wrong type" do
      expect { klass.to_native(Object.new, nil) }.to raise_error(TypeError, /expected a kind of/)
    end
  end

  describe "#type_class" do
    it "defaults to the class itself" do
      klass.type_class.should eq klass
    end
  end
end
