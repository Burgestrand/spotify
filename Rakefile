require 'bundler/setup'

Bundler::GemHelper.install_tasks

require 'yard'
YARD::Rake::YardocTask.new('yard:doc') do |task|
  task.options = ['--no-stats']
end

task 'yard:stats' do
  YARD::CLI::Stats.run('--list-undoc')
end

task :yard => ['yard:doc', 'yard:stats']

desc "Run code benchmarks"
task :bench do
  sh "ruby", "spec/bench_helper.rb"
end

desc "re-generate spec/api.h.xml"
task :gen do
  Dir["spec/support/api-*.h"].each do |header|
    sh "gccxml", header, "-fxml=#{header.sub('.h', '.xml')}"
  end
end

task :console do
  exec "pry", "-Ilib", "-rspotify"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:test_mac) do |spec|
  spec.ruby_opts = ['-r ./spec/support/mac-platform', '-W']
end

RSpec::Core::RakeTask.new(:test_linux) do |spec|
  spec.ruby_opts = ['-r ./spec/support/linux-platform', '-W']
end

desc "Run the tests for both Linux and Mac OS"
task :default => [:test_mac, :test_linux]
