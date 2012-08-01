# encoding: utf-8
describe SpotifyAPI::UTF8String do
  module C
    extend FFI::Library
    ffi_lib [FFI::CURRENT_PROCESS, 'c']

    attach_function :strncpy, [ :pointer, SpotifyAPI::UTF8String, :size_t ], SpotifyAPI::UTF8String
  end

  let(:char) do
    char = "\xC4"
    char.force_encoding('ISO-8859-1')
    char
  end

  it "should convert any strings to UTF-8 before reading and writing" do
    dest   = FFI::MemoryPointer.new(:char, 3) # two bytes for the ä, one for the NULL
    result = C.strncpy(dest, char, 3)

    result.encoding.should eq Encoding::UTF_8
    result.should eq "Ä"
    result.bytesize.should eq 2
  end
end
