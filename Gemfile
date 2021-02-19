source 'https://rubygems.org'

gemspec

group :development do
  gem 'awesome_print'
  gem 'pry', platforms: %i[jruby rbx]
  gem 'pry-byebug', platforms: :mri
  gem 'yard-junk'
  gem 'rubocop-performance'

  # WIP
  gem 'dry-monitor'         # @see bin/console
  gem 'rouge'               # @see lib/dry/monitor/ldap/logger.rb
end

group :test do
  gem 'libxml-ruby'         # @see spec/unit/relation/export_spec.rb
  gem 'msgpack', '~> 1.2.4' # @see spec/unit/relation/export_spec.rb
  gem 'oj'                  # @see spec/unit/relation/export_spec.rb
  gem 'rom' do
    gem 'rom-changeset'
    gem 'rom-core'
    gem 'rom-mapper'
    gem 'rom-repository'
  end
  gem 'rom-factory'
  gem 'rspec'
  gem 'simplecov'

  # WIP
  # gem 'rom-sql'             # @see spec/integration/rom_sql_spec.rb
  # gem 'rubyntlm'            # @see spec/unit ...
  # gem 'sqlite3'             # @see spec/integration/rom_sql_spec.rb
end

group :benchmark do
  gem 'benchmark-ips'
  gem 'net-ldap'
end
