# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'saddle'
  s.version       = '0.0.1'
  s.authors       = ['Mike Lewis', 'Naseem Hakim']
  s.email         = 'mike@cleverkoala.com'
  s.description   = %q{Makes writing API clients as easy as giving high fives}
  s.summary       = %q{
    A generic client wrapper for building service-specific wrappers. Base functionality, meant to be extended to concrete implementations.
  }
  s.homepage    = 'https://github.com/mLewisLogic/saddle'

  s.add_dependency 'activesupport', '~> 3.2.13'
  s.add_dependency 'faraday', '~> 0.8.6'
  s.add_dependency 'faraday_middleware', '~> 0.9.0'
end
