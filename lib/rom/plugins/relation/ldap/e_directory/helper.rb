# NETWARE_SERVERS = '(objectClass=ncpServer)'.freeze
# NETWARE_VOLUMES = '(objectClass=volume)'.freeze
# ZEN_APPLICATION = '(objectClass=appApplication)'.freeze
# # https://confluence.atlassian.com/kb/how-to-write-ldap-search-filters-792496933.html
# dn_part_match = '(|(ou:dn:=Chicago)(ou:dn:=Miami)))'.freeze


module ROM
  module Plugins
    module Relation
      module LDAP
        module EDirectory
          # Novell eDirectory specific extension.
          #
          # @api public
          module Helper
          end

        end
      end
    end
  end
end

ROM.plugins do
  adapter :ldap do
    register :ed_helper, ROM::Plugins::Relation::LDAP::EDirectory::Helper, type: :relation
  end
end
