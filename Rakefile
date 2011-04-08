require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
Rake::TestTask.new do |spec|
  spec.ruby_opts = ['-rminitest/spec', '-rminitest/autorun']
  spec.pattern = 'spec/*_spec.rb'
end