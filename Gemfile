source 'https://rubygems.org'

gemspec

gem 'rom-core', github: 'rom-rb/rom', branch: 'master'
gem 'ldap-ber', git: 'ssh://git@bitbucket.org/mrpeterpeter/ldap-ber', branch: 'develop'

group :test do
  gem 'codeclimate-test-reporter', require: false
  gem 'msgpack', '~> 1.2.4'
  gem 'pry-byebug', platforms: :mri
  gem 'rom-factory', '~> 0.5', require: false
  gem 'rspec', '~> 3.8'
  gem 'rubocop', '~> 0.58'
  gem 'simplecov', require: false
end
