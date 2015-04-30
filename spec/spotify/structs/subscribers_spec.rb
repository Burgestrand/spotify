describe Spotify::Subscribers do
  describe "#initialize" do
    context "given a null pointer" do
      subject(:subscribers) do
        Spotify::Subscribers.new(FFI::Pointer::NULL)
      end

      it "is null" do
        is_expected.to be_null
      end

      it "protects against referencing non-allocated memory" do
        expect { subscribers[:count] }.to raise_error(FFI::NullPointerError)
      end

      it "is empty" do
        expect(subscribers.to_a).to be_empty
      end
    end

    context "given an empty struct pointer" do
      let(:memory) do
        pointer = FFI::MemoryPointer.new(:uint)
        pointer.write_uint(0)
        pointer
      end

      subject(:subscribers) do
        pointer = FFI::Pointer.new(memory.address)
        Spotify::Subscribers.new(pointer)
      end

      specify do
        expect(subscribers[:count]).to be_zero
      end

      it "is empty" do
        expect(subscribers.to_a).to be_empty
      end
    end

    context "given a filled struct pointer" do
      let(:memory) do
        klass = Class.new(Spotify::Struct) do
          layout count: :uint,
                 a: Spotify::UTF8StringPointer,
                 b: Spotify::UTF8StringPointer
        end

        klass.new.tap do |struct|
          struct[:count] = 2
          struct[:a] = "Alpha"
          struct[:b] = "Beta"
        end
      end

      subject(:subscribers) do
        Spotify::Subscribers.new(memory.pointer)
      end

      it "has the correct count" do
        expect(subscribers[:count]).to eq 2
      end

      it "contains the subscribers" do
        expect(subscribers[:subscribers][0]).to eq "Alpha"
        expect(subscribers[:subscribers][1]).to eq "Beta"
      end
    end

    context "given an integer count" do
      subject(:subscribers) do
        Spotify::Subscribers.new(2)
      end

      it "allocates memory for a `count` sized subscribers" do
        expect(subscribers[:subscribers].size).to eq 2
      end

      it "assigns count to the correct count" do
        expect(subscribers[:count]).to eq 2
      end
    end
  end

  describe "#[:subscribers]" do
    it "raises an error when referencing a value out of bounds" do
      subscribers = Spotify::Subscribers.new(2)
      expect { subscribers[:subscribers][2] }.to raise_error(IndexError)
    end
  end

  describe "#each" do
    subject(:subscribers) do
      Spotify::Subscribers.new(3).tap do |struct|
        struct[:count] = 3
        struct[:subscribers][0] = "Alpha"
        struct[:subscribers][1] = "Beta"
        struct[:subscribers][2] = "Gamma"
      end
    end

    it "returns an enumerator when not given a block" do
      expect(subscribers.each).to be_a Enumerator
    end

    it "returns an enumerator with a defined size when not given a block", :ruby_version => ">= 2.0.0" do
      expect(subscribers.each.size).to eq 3
    end

    it "yields every subscriber as an UTF-8 encoded string" do
      strings = subscribers.to_a
      expect(strings).to eq %w[Alpha Beta Gamma]
      expect(strings.map(&:encoding).uniq).to eq [Encoding::UTF_8]
    end
  end
end
