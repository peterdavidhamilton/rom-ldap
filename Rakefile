if ENV['DEBUG']
  # rubocop:disable Lint/SuppressedException
  begin
    require 'pry-byebug'
  rescue LoadError
  end
  # rubocop:enable Lint/SuppressedException
end

require 'bundler/gem_tasks'

load 'rom/ldap/tasks/ldap.rake'
load 'rom/ldap/tasks/ldif.rake'

# LDAPURI=ldap://localhost:1389 LDAPBINDDN=uid=admin,ou=system LDAPBINDPW=secret LDAPDIR=./spec/fixtures/ldif rake ldap:modify
#
task default: [:spec]
