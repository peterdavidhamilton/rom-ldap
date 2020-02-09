source 'https://rubygems.org'

gemspec

gem 'ldap-ber', git: "https://oauth2:#{ENV['GITLAB_TOKEN']}@gitlab.com/peterdavidhamilton/ldap-ber", branch: 'develop'

gem 'rom', git: 'https://github.com/rom-rb/rom' do
  gem 'rom-changeset'
  gem 'rom-core'
  gem 'rom-mapper'
  gem 'rom-repository'
end

group :development do
  gem 'awesome_print'
  gem 'pry', platforms: %i[jruby rbx]
  gem 'pry-byebug', platforms: :mri
  gem 'yard-junk'
  gem 'rubocop-performance'

  gem 'dry-monitor'         # @see bin/console
  gem 'rouge'               # @see lib/dry/monitor/ldap/logger.rb
end

group :test do
  gem 'msgpack', '~> 1.2.4' # @see spec/unit/relation/export_spec.rb
  gem 'libxml-ruby'         # @see spec/unit/relation/export_spec.rb
  gem 'rom-factory'
  gem 'rspec'
  gem 'simplecov'

  # gem 'rails'               # @see spec/integration/rails_sql_spec.rb
  # gem 'rom-sql'             # @see spec/integration/rails_sql_spec.rb
  # gem 'rubyntlm'            # @see spec/unit ...
  # gem 'sqlite3'             # @see spec/integration/rails_sql_spec.rb
end

group :benchmark do
  gem 'benchmark-ips'
  gem 'net-ldap'
end
