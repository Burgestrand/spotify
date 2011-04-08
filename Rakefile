require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
Rake::TestTask.new do |spec|
  spec.pattern = 'spec/*_spec.rb'
end

require 'yard'
YARD::Rake::YardocTask.new

task :spec => :test
task :default => :test