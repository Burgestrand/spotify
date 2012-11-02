module Spotify
  class << API
    def bogus_add_ref(x)
    end

    def bogus_release(x)
    end
  end

  class Bogus < ManagedPointer
  end
end

one   = FFI::Pointer.new(1)
null  = FFI::Pointer::NULL

album = Spotify::Album.new(one)
album.autorelease = false

bench "Album#to_native" do
  Spotify::Album.to_native(album, nil)
end

bench "Bogus#retain" do
  Spotify::Bogus.retain(one)
  Spotify::Bogus.retaining_class.retain(one)
end

bench "Bogus#release" do
  Spotify::Bogus.release(one)
  Spotify::Bogus.retaining_class.release(one)
end
