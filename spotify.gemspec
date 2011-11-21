# -*- encoding: utf-8 -*-
require './lib/spotify/version'

Gem::Specification.new do |gem|
  gem.name        = 'spotify'
  gem.summary     = 'Bare-bones Ruby bindings for libspotify'
  gem.description = <<-DESC
    Spotify for Ruby is merely a very simple wrapper around libspotify
    using Ruby FFI. If you wish for a simpler and (better) API, check
    out Hallon (https://rubygems.org/gems/hallon)!
  DESC

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

  gem.add_dependency 'ffi', ['~> 1.0', '>= 1.0.11']
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'yard'
  gem.add_development_dependency 'rbgccxml'
  gem.add_development_dependency 'gccxml_gem', '!= 0.9.3'
  gem.add_development_dependency 'minitest', '~> 2.0'
  gem.add_development_dependency 'bundler', '~> 1.0'
end
