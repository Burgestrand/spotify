album = Spotify::Album.new(FFI::Pointer::NULL)

bench "ManagedPointer#to_native" do
  Spotify::Album.to_native(album, nil)
end
