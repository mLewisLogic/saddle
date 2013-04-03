# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'saddle'
  gem.version       = '0.0.1'
  gem.authors       = ['Mike Lewis']
  gem.email         = ['mike.lewis@airbnb.com']
  gem.description   = %q{Makes writing API clients as easy as giving high fives}
  gem.summary       = %q{
    A generic client wrapper for building service-specific wrappers. Base functionality, meant to be extended to concrete implementations.
  }

  gem.add_dependency 'activesupport', '~> 3.2.13'
  gem.add_dependency 'faraday', '~> 0.8.6'
  gem.add_dependency 'faraday_middleware', '~> 0.9.0'
end
