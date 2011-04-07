# -*- encoding: utf-8 -*-
require './lib/spotify/version'

Gem::Specification.new do |gem|
  gem.name        = 'spotify'
  gem.summary     = 'Clean-cut Ruby bindings to libspotify'
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
  
  gem.add_dependency 'ffi', '~> 1.0.0'
end