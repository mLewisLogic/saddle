# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'apiwrapper'
  gem.version       = '0.0.1'
  gem.authors       = ['Mike Lewis']
  gem.email         = ['mike.lewis@airbnb.com']
  gem.description   = %q{A generic client wrapper for building service-specific wrappers}
  gem.summary       = %q{
    Base functionality, meant to be extended to concrete implementations.
  }

  gem.add_dependency 'faraday', '~> 0.8.6'
  gem.add_dependency 'typhoeus', '~> 0.6.2'
end
