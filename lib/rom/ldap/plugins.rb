require 'rom/plugins/relation/ldap/instrumentation'
require 'rom/plugins/relation/ldap/auto_restrictions'
require 'rom/ldap/plugin/pagination'

ROM.plugins do
  adapter :ldap do
    register :pagination, ROM::LDAP::Plugin::Pagination, type: :relation
  end
end
