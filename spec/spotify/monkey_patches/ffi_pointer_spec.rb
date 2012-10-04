describe "#read_size_t" do
  it "is defined on FFI::Pointer" do
    FFI::Pointer.new(0).should respond_to(:read_size_t)
  end

  it "is defined on FFI::Buffer" do
    FFI::Buffer.new(0).should respond_to(:read_size_t)
  end
end
