require "stringio"

class InterceptIO
  class << self
    def def_interceptor(method)
      define_method(method) do |*args, &block|
        @io.public_send(method, *args, &block) unless @suppress
        @buffer.public_send(method, *args, &block)
      end
    end
  end

  def initialize(io, suppress: false)
    @io = io
    @buffer = StringIO.new
    @suppress = suppress
  end

  attr_reader :io

  def_interceptor :write
  def_interceptor :print
  def_interceptor :puts
  def_interceptor :tty?

  def read
    @buffer.rewind
    @buffer.read
  end
end

def spy_output(suppress = false)
  $stdout = InterceptIO.new($stdout, suppress: suppress)
  $stderr = InterceptIO.new($stderr, suppress: suppress)
  yield
  [$stdout.read, $stderr.read]
ensure
  $stderr = $stderr.io
  $stdout = $stdout.io
end
