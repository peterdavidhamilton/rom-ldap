# encoding: utf-8
# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rom/ldap/version'

Gem::Specification.new do |spec|
  spec.name          = 'rom-ldap'
  spec.version       = ROM::Ldap::VERSION.dup
  spec.authors       = ['Peter Hamilton']
  spec.email         = ['pete@peterdavidhamilton.com']
  spec.summary       = 'LDAP directory support for ROM'
  spec.description   = spec.summary
  spec.homepage      = 'http://rom-rb.org'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'net-ldap', '~> 0.15.0'
  spec.add_runtime_dependency 'dry-initializer'
  spec.add_runtime_dependency 'dry-types'
  spec.add_runtime_dependency 'rom'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'ladle'
  spec.add_development_dependency 'rake', '~> 10.0'
end
