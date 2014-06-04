# -*- encoding: utf-8 -*-
require './lib/spotify/version'

Gem::Specification.new do |gem|
  gem.name        = 'spotify'
  gem.summary     = 'Low-level Ruby bindings for libspotify, the official Spotify C API'

  gem.homepage    = 'https://github.com/Burgestrand/spotify'
  gem.authors     = ["Kim Burgestrand"]
  gem.email       = ['kim@burgestrand.se']
  gem.license     = 'MIT License'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = []
  gem.require_paths = ["lib"]

  gem.version = Spotify::VERSION
  gem.platform = Gem::Platform::RUBY
  gem.required_ruby_version = '>= 1.9'

  gem.add_dependency 'ffi', ['~> 1.0', '>= 1.0.11']
  gem.add_dependency 'libspotify', '~> 12.1.51'
  gem.add_dependency 'performer', '~> 1.0'

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rbgccxml'
  gem.add_development_dependency 'rspec'
end
