# coding: utf-8
describe Spotify::ManagedPointer do
  let(:klass) { described_class }
  let(:null) { FFI::Pointer::NULL }
  let(:pointer) { FFI::Pointer.new(1) }
  let(:subject) do
    Class.new(Spotify::ManagedPointer) do
      def initialize(*)
        super
        self.autorelease = false
      end

      def self.name
        "Anonymous"
      end
    end
  end

  it "adds a ref if it is a retaining class" do
    api.should_receive(:anonymous_add_ref)
    ptr = subject.retaining_class.new(FFI::Pointer.new(1))
  end

  it "does not add or release when the pointer is null" do
    api.should_not_receive(:anonymous_add_ref)
    api.should_not_receive(:anonymous_release)

    ptr = subject.retaining_class.new(FFI::Pointer::NULL)
    ptr.free
  end

  describe "#release" do
    it "wraps the release pointer properly to avoid type-failures" do
      api.should_receive(:anonymous_release).and_return do |pointer|
        pointer.should be_instance_of(subject)
        pointer.should_not be_autorelease # autorelease should be off
      end

      ptr = subject.new(FFI::Pointer.new(1))
      ptr.free
    end
  end

  describe ".to_native" do
    it "does not accept null pointers" do
      expect { subject.to_native(nil, nil) }.to raise_error(TypeError, /cannot be null/)
      expect { subject.to_native(Spotify::Session.new(null), nil) }.to raise_error(TypeError, /cannot be null/)
    end

    it "does not accept pointers of another type" do
      expect { subject.to_native(pointer, nil) }.to raise_error(TypeError, /expected a kind of Anonymous/)
      expect { subject.to_native(Spotify::Session.new(pointer), nil) }.to raise_error(TypeError, /expected a kind of Anonymous/)
    end

    it "accepts pointers of the same kind, or a subkind" do
      api.stub(:anonymous_add_ref)

      retaining = subject.retaining_class.new(pointer)
      retaining.autorelease = false

      regular = subject.new(pointer)
      regular.autorelease = false

      expect { subject.to_native(retaining, nil) }.to_not raise_error
      expect { subject.to_native(regular, nil) }.to_not raise_error
      expect { subject.retaining_class.to_native(retaining, nil) }.to_not raise_error
      expect { subject.retaining_class.to_native(regular, nil) }.to_not raise_error
    end
  end

  describe "garbage collection" do
    module Spotify
      class << API
        def bogus_add_ref(pointer)
        end

        def bogus_release(pointer)
        end
      end

      class Bogus < ManagedPointer
      end
    end

    let(:my_pointer) { FFI::Pointer.new(1) }

    it "should work" do
      api.stub(:bogus_add_ref)

      # GC tests are a bit funky, but as long as we garbage_release at least once, then
      # we can assume our GC works properly, but up the stakes just for the sake of it
      api.should_receive(:bogus_release).at_least(1).times

      5.times { Spotify::Bogus.retaining_class.new(FFI::Pointer.new(1)) }
      5.times { GC.start; sleep 0.01 }
    end
  end

  describe "all managed pointers" do
    Spotify.constants.each do |const|
      klass = Spotify.const_get(const)
      next unless klass.is_a?(Class)
      next unless klass < Spotify::ManagedPointer

      it "#{klass.name} has a valid retain method" do
        Spotify.should_receive(:public_send).and_return do |method, *args|
          Spotify.should respond_to(method)
          method.should match /_add_ref$/
        end

        klass.retain(FFI::Pointer.new(1))
      end unless klass == Spotify::Session # has no valid retain

      it "#{klass.name} has a valid release method" do
        Spotify.should_receive(:public_send).and_return do |method, *args|
          Spotify.should respond_to(method)
          method.should match /_release$/
        end

        klass.release(FFI::Pointer.new(1))
      end
    end
  end
end
