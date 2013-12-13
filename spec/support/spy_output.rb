require "stringio"

def spy_output(suppress = false)
  old_out, $stdout = $stdout, StringIO.new
  old_err, $stderr = $stderr, StringIO.new
  yield
  out = $stdout.tap(&:rewind).read
  err = $stderr.tap(&:rewind).read
  [out, err]
ensure
  old_out.write(out) if not suppress and out
  old_err.write(err) if not suppress and err

  $stderr = old_err
  $stdout = old_out
end
