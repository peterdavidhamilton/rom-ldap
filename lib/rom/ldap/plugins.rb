require 'rom/plugins/relation/ldap/instrumentation'
require 'rom/ldap/plugin/pagination'

ROM.plugins do
  adapter :ldap do
    register :pagination, ROM::LDAP::Plugin::Pagination, type: :relation
  end
end
