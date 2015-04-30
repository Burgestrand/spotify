describe "#read_size_t" do
  it "is defined on FFI::Pointer" do
    expect(FFI::Pointer.new(0)).to respond_to(:read_size_t)
  end

  it "is defined on FFI::Buffer" do
    expect(FFI::Buffer.new(0)).to respond_to(:read_size_t)
  end
end
