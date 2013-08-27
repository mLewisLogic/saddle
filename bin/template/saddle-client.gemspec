# -*- encoding: utf-8 -*-

require File.expand_path('../lib/<%= project_name %>/version', __FILE__)

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name          = '<%= project_name %>'
  s.version       = ::<%= root_module %>::VERSION
  s.authors       = ['<%= author_name %>']
  s.email         = ['<%= author_email %>']
  s.description   = %q{<%= service_name %> client}
  s.summary       = %q{
    This is a <%= service_name %> client implemented on Saddle
  }
  s.homepage      = 'https://github.com/<%= github_account %>/<%= project_name %>'
  s.license       = 'MIT'

  s.require_path  = 'lib'
  s.files         = `git ls-files`.split($\)
  s.executables   = s.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  s.add_dependency 'saddle', '~> <%= saddle_version %>'
end
