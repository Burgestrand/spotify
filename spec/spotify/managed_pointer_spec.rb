describe Spotify::ManagedPointer do
  it "adds a ref if it is a retaining class" do
    Spotify.should_receive(:user_add_ref)
    ptr = Spotify::User.retaining_class.new(FFI::Pointer.new(1))
    ptr.autorelease = false # avoid auto-GC after test
  end

  it "does not add or release when the pointer is null" do
    Spotify.should_not_receive(:user_add_ref)
    Spotify.should_not_receive(:user_release)

    ptr = Spotify::User.retaining_class.new(FFI::Pointer::NULL)
    ptr.free
  end

  describe "garbage collection" do
    module Spotify
      def bogus_add_ref(pointer)
      end

      def bogus_release(pointer)
      end

      class Bogus < ManagedPointer
      end
    end

    let(:my_pointer) { FFI::Pointer.new(1) }

    it "should work" do
      Spotify.stub(:bogus_add_ref)

      # GC tests are a bit funky, but as long as we garbage_release at least once, then
      # we can assume our GC works properly, but up the stakes just for the sake of it
      Spotify.should_receive(:bogus_release).at_least(1).times

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
