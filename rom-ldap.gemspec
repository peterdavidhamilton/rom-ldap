# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'rom/ldap/version'

Gem::Specification.new do |gem|
  gem.name = 'rom-ldap'
  gem.authors = ['Peter Hamilton']
  gem.email = ['pete@peterdavidhamilton.com']
  gem.summary = 'LDAP support for ROM'
  gem.description = gem.summary
  gem.post_install_message = <<~EOF
    ROM-LDAP would not be possible without the hard work of contributors
    to the ruby-net-ldap gem, whose code it is inspired by.

    THANK YOU
    https://pdhamilton.uk
  EOF
  gem.license = 'MIT'
  gem.homepage = 'https://rom-rb.org'
  gem.metadata    = {
    'source_code_uri'   => 'https://gitlab.com/peterdavidhamilton/rom-ldap',
    'bug_tracker_uri'   => 'https://gitlab.com/peterdavidhamilton/rom-ldap/issues',
    'wiki_uri'          => 'https://gitlab.com/peterdavidhamilton/rom-ldap/wikis',
    'documentation_uri' => 'https://pdhamilton.uk/projects/rom-ldap',
    'mailing_list_uri'  => 'https://discourse.rom-rb.org/',
  }

  gem.version = ROM::LDAP::VERSION.dup
  gem.files = Dir['*.md', 'lib/**/*', 'config/*.yml']
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']
  gem.required_ruby_version = '>= 2.4'
  
  gem.add_runtime_dependency 'dry-transformer', '~> 0.1'
  gem.add_runtime_dependency 'ldap-ber', '~> 0.1'
  gem.add_runtime_dependency 'rom', '>= 5.2'

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'rspec', '~> 3.9'
end
