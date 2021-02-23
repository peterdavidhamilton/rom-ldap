# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rom/ldap/version'

Gem::Specification.new do |spec|
  spec.name = 'rom-ldap'
  spec.version = ROM::LDAP::VERSION.dup
  spec.authors = ['Peter Hamilton']
  spec.email = ['pete@peterdavidhamilton.com']
  spec.summary = 'lightweight directory adapter for ROM'
  spec.description = <<~EOF
    ROM-LDAP is a Ruby Object Mapper gateway adapter for LDAP.
    This gem is a reworking of NET::LDAP for use with ROM.
  EOF
  spec.homepage = 'https://rom-rb.org'
  spec.license = 'MIT'
  spec.files = Dir['*.md', 'lib/**/*', 'config/*.yml']
  spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.required_ruby_version = '~> 2.4'

  spec.add_runtime_dependency 'dry-transformer', '~> 0.1'
  spec.add_runtime_dependency 'ldap-ber', '~> 0.1'
  spec.add_runtime_dependency 'rom-core', '~> 5.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
end
