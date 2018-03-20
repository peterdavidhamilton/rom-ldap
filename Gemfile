# bundle config local.ldap-ber ~/Code/ldap-ber
source 'https://rubygems.org'

gemspec

gem 'ldap-ber', git: 'bb:ldap-ber', branch: 'develop'

group :test do
  gem 'codeclimate-test-reporter', require: false
  gem 'msgpack'
  gem 'pry', platforms: %i[jruby rbx]
  gem 'pry-byebug', platforms: :mri
  gem 'rom-factory', '~> 0.5.0', require: false
  gem 'rspec'
  gem 'rubocop'
  gem 'simplecov', require: false
end
