lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rom/ldap/version'

Gem::Specification.new do |spec|
  spec.name        = 'rom-ldap'
  spec.version     = ROM::LDAP::VERSION.dup
  spec.authors     = ['Peter Hamilton']
  spec.email       = ['pete@peterdavidhamilton.com']
  spec.summary     = 'LDAP directory support for ROM'
  spec.description = spec.summary
  spec.homepage    = 'http://rom-rb.org'
  spec.license     = 'MIT'

  # use "yard" to  ld full HTML docs.
  spec.metadata['yard.run'] = 'yri'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3.0'

  spec.add_runtime_dependency 'dry-core', '~> 0.4'
  spec.add_runtime_dependency 'dry-types', '>= 0.12'
  spec.add_runtime_dependency 'dry-struct', '~> 0.5'
  spec.add_runtime_dependency 'rom-core', '>= 4.2'
  spec.add_runtime_dependency 'dry-monitor', '~> 0.1'
  spec.add_runtime_dependency 'net_tcp_client', '~> 2.0'
  spec.add_runtime_dependency 'ldap-ber', '~> 0.0.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake', '> 12.0'
  spec.add_development_dependency 'rspec', '~> 3.5'
end
