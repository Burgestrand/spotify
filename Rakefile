require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake/testtask'
Rake::TestTask.new do |spec|
  spec.pattern = 'spec/*_spec.rb'
end

require 'yard'
YARD::Rake::YardocTask.new

desc "re-generate spec/api.h.xml"
task :gen do
  sh 'gccxml spec/api.h -fxml=spec/api.h.xml'
end

task :spec => :test
task :default => :test
