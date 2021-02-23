# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rom/ldap/version'

Gem::Specification.new do |gem|
  gem.name = 'rom-ldap'
  gem.description = 'lightweight directory adapter for ROM'
  gem.authors = ['Peter Hamilton']
  gem.email = ['pete@peterdavidhamilton.com']
  gem.summary = <<~EOF
    ROM-LDAP is a Ruby Object Mapper gateway adapter for LDAP.
  EOF
  gem.homepage = 'https://rom-rb.org'

  gem.metadata    = {
    'source_code_uri'   => 'https://github.com/peterdavidhamilton/rom-ldap',
    'documentation_uri' => 'https://api.rom-rb.org/rom/',
    'mailing_list_uri'  => 'https://discourse.rom-rb.org/',
    'bug_tracker_uri'   => 'https://github.com/peterdavidhamilton/rom-ldap/issues',
  }

  gem.license = 'MIT'
  gem.version = ROM::LDAP::VERSION.dup
  gem.files = Dir['*.md', 'lib/**/*', 'config/*.yml']
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 2.4'

  gem.add_runtime_dependency 'ldap-ber', '~> 0.1'
  gem.add_runtime_dependency 'rom', '~> 6.0'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'rspec', '~> 3.9'
end
