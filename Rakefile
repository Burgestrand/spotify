begin
  require 'bundler'
  Bundler::GemHelper.install_tasks
rescue LoadError
  # do not require bundler rake tasks
end


require 'yard'
YARD::Rake::YardocTask.new

desc "re-generate spec/api.h.xml"
task :gen do
  sh 'gccxml spec/api.h -fxml=spec/api.h.xml'
end

task :console do
  exec "irb", "-Ilib", "-rspotify"
end

require 'rake/testtask'
Rake::TestTask.new(:test_mac) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.ruby_opts = ['-r ./spec/mac-platform']
end

Rake::TestTask.new(:test_linux) do |spec|
  spec.pattern = 'spec/*_spec.rb'
  spec.ruby_opts = ['-r ./spec/linux-platform']
end

desc "Run the tests for both Linux and Mac OS"
task :default => [:test_mac, :test_linux]
