# -*- encoding: utf-8 -*-
require File.expand_path('../lib/saddle/version', __FILE__)

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name          = 'saddle'
  s.version       = Saddle::VERSION

  s.authors       = ['Mike Lewis']
  s.email         = 'mike.lewis@airbnb.com'
  s.description   = %q{Makes writing API clients as easy as giving high fives}
  s.summary       = %q{
    A full-featured, generic consumer layer for you to build API client implementations with.
  }
  s.homepage      = 'https://github.com/mLewisLogic/saddle'
  s.license       = 'MIT'

  s.require_path  = 'lib'
  s.files         = `git ls-files`.split($\)
  s.executables   = ['saddle']
  s.test_files    = s.files.grep(%r{^(spec)/})
  
  s.add_dependency 'activesupport', '~> 3.0'
  s.add_dependency 'faraday', '~> 0.8.7'
  s.add_dependency 'faraday_middleware', '~> 0.9.0'
end
