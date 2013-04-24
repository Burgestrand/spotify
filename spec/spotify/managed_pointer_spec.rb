# coding: utf-8
describe Spotify::ManagedPointer do
  let(:klass) { described_class }
  let(:null) { FFI::Pointer::NULL }
  let(:pointer) { FFI::Pointer.new(1) }
  let(:klass) { Spotify::User }
  let(:retaining_klass) { klass.retaining_class }

  it "adds a ref if it is a retaining class" do
    api.should_receive(:user_add_ref)
    ptr = retaining_klass.new(FFI::Pointer.new(1))
    ptr.autorelease = false
  end

  it "does not add or release when the pointer is null" do
    api.should_not_receive(:user_add_ref)
    api.should_not_receive(:user_release)

    ptr = retaining_klass.new(FFI::Pointer::NULL)
    ptr.free
    ptr.should_not be_autorelease
  end

  describe "#release" do
    it "wraps the release pointer properly to avoid type-failures" do
      api.should_receive(:user_release).and_return do |pointer|
        pointer.should be_instance_of(klass)
        pointer.should_not be_autorelease # autorelease should be off
      end

      ptr = klass.new(FFI::Pointer.new(1))
      ptr.free
      ptr.should_not be_autorelease
    end
  end

  describe ".to_native" do
    it "does not accept null pointers" do
      expect { klass.to_native(nil, nil) }.to raise_error(TypeError, /cannot be null/)
      expect { klass.to_native(Spotify::Session.new(null), nil) }.to raise_error(TypeError, /cannot be null/)
    end

    it "does not accept pointers of another type" do
      expect { klass.to_native(pointer, nil) }.to raise_error(TypeError, /expected a kind of Spotify::User/)
      expect { klass.to_native(Spotify::Session.new(pointer), nil) }.to raise_error(TypeError, /expected a kind of Spotify::User/)
    end

    it "accepts pointers of the same kind, or a subkind" do
      api.stub(:user_add_ref)

      retaining = retaining_klass.new(pointer)
      retaining.autorelease = false

      regular = klass.new(pointer)
      regular.autorelease = false

      expect { klass.to_native(retaining, nil) }.to_not raise_error
      expect { klass.to_native(regular, nil) }.to_not raise_error
      expect { retaining_klass.to_native(retaining, nil) }.to_not raise_error
      expect { retaining_klass.to_native(regular, nil) }.to_not raise_error
    end
  end

  describe ".size" do
    it "returns the size of a pointer" do
      Spotify::ManagedPointer.size.should eq FFI.type_size(:pointer)
    end
  end

  # We only test this on MRI, since it does not work in quite
  # the same way on JRuby nor Rubinius with regards to the GC.
  #
  # Luckily, if it works on MRI, we should be able to assume
  # that it works on JRuby and Rubinius too.
  describe "garbage collection", :engine => "ruby" do
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
          method.should match(/_add_ref$/)
        end

        klass.retain(FFI::Pointer.new(1))
      end unless klass == Spotify::Session # has no valid retain

      it "#{klass.name} has a valid release method" do
        Spotify.should_receive(:public_send).and_return do |method, *args|
          Spotify.should respond_to(method)
          method.should match(/_release$/)
        end

        klass.release(FFI::Pointer.new(1))
      end
    end
  end
end
