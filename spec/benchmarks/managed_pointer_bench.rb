module Spotify
  class << API
    def bogus_add_ref(x)
    end
  end

  class Bogus < ManagedPointer
  end
end

one   = FFI::Pointer.new(1)
null  = FFI::Pointer::NULL
album = Spotify::Album.new(null)

bench "Album#to_native" do
  Spotify::Album.to_native(album, nil)
end

bench "Album#retain" do
  Spotify::Bogus.retain(one)
end
