begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
rescue LoadError
  # do not require bundler rake tasks
end

begin
  require 'yard'
  YARD::Rake::YardocTask.new('yard:doc') do |task|
    task.options = ['--no-stats']
  end

  task 'yard:stats' do
    YARD::CLI::Stats.run('--list-undoc')
  end

  task :yard => ['yard:doc', 'yard:stats']
rescue LoadError
  puts "WARN: YARD not available. You may install documentation dependencies via bundler."
end

desc "Run code benchmarks"
task :bench do
  sh "ruby", "spec/bench_helper.rb"
end

desc "re-generate spec/api.h.xml"
task :gen do
  Dir["spec/api-*.h"].each do |header|
    sh "gccxml", header, "-fxml=#{header.sub('.h', '.xml')}"
  end
end

task :console do
  exec "irb", "-Ilib", "-rspotify"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:test_mac) do |spec|
  spec.ruby_opts = ['-r ./spec/mac-platform']
end

RSpec::Core::RakeTask.new(:test_linux) do |spec|
  spec.ruby_opts = ['-r ./spec/linux-platform']
end

desc "Run the tests for both Linux and Mac OS"
task :default => [:test_mac, :test_linux]
