source 'https://rubygems.org'

gemspec

gem 'rom-core', git: 'ssh://git@github.com/rom-rb/rom', branch: 'master'
gem 'ldap-ber', git: 'ssh://git@bitbucket.org/mrpeterpeter/ldap-ber', branch: 'develop'

group :test do
  gem 'codeclimate-test-reporter', require: false
  gem 'msgpack', '~> 1.2.4', require: false # @see spec/unit/relation/export_spec.rb
  gem 'pry-byebug', platforms: :mri
  gem 'faker', github: 'stympy/faker', branch: 'master', require: false
  gem 'rom-factory', github: 'rom-rb/rom-factory', branch: 'master', require: false
  gem 'rspec', '~> 3.8'
  gem 'rubocop', '~> 0.58', require: false
  gem 'simplecov', require: false
end
