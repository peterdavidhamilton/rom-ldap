lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rom/ldap/version'

Gem::Specification.new do |spec|
  spec.name          = 'rom-ldap'
  spec.version       = ROM::LDAP::VERSION.dup
  spec.authors       = ['Peter Hamilton']
  spec.email         = ['pete@peterdavidhamilton.com']
  spec.summary       = 'LDAP directory support for ROM'
  spec.description   = spec.summary
  spec.homepage      = 'http://rom-rb.org'
  spec.license       = 'MIT'

  # use "yard" to build full HTML docs.
  spec.metadata['yard.run'] = 'yri'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_runtime_dependency 'dry-core', '~> 0.3'
  spec.add_runtime_dependency 'dry-types', '~> 0.12'
  spec.add_runtime_dependency 'rom-core', '~> 4.0'
  spec.add_runtime_dependency 'transproc'
  spec.add_runtime_dependency 'net-ldap'
  spec.add_runtime_dependency 'net_tcp_client'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  # spec.add_development_dependency 'minitest'
  # spec.add_development_dependency 'rom-factory'
end
