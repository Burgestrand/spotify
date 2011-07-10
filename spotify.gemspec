# -*- encoding: utf-8 -*-
require './lib/spotify/version'

Gem::Specification.new do |gem|
  gem.name        = 'spotify'
  gem.summary     = 'Bare-bones Ruby bindings for libspotify'
  gem.homepage    = 'https://github.com/Burgestrand/libspotify-ruby'
  gem.authors     = ["Kim Burgestrand"]
  gem.email       = ['kim@burgestrand.se']
  gem.license     = 'X11 License'

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = []
  gem.require_paths = ["lib"]

  gem.version     = Spotify::VERSION
  gem.platform    = Gem::Platform::RUBY

  gem.requirements << 'libspotify, v0.0.8'
  gem.add_dependency 'ffi', '~> 1.0.0'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'rbgccxml'
  gem.add_development_dependency 'turn'
  gem.add_development_dependency 'minitest', '~> 2.0.0'
  gem.add_development_dependency 'bundler', '~> 1.0.0'
end
