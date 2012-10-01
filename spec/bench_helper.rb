require 'spotify'
require 'benchmark'
require 'pry'

$__benchmarks__ = []

def bench(name, iterations = 100_000, &block)
  file, line, _ = caller[0].split(':')
  $__benchmarks__ << {
    file: File.basename(file),
    line: line,
    name: name,
    iterations: iterations,
    block: block
  }
end

at_exit do
  Benchmark.bmbm do |x|
    $__benchmarks__.each do |info|
      benchname = "#{info[:file]}:#{info[:line]} #{info[:name]}"
      x.report(benchname) { info[:iterations].times(&info[:block]) }
    end
  end
end

Dir["./**/*_bench.rb"].each do |benchmark|
  require benchmark
end
