# frozen_string_literal: true

module ROM
  module Plugins
    module Relation
      module LDAP
        # Novell eDirectory specific extension.
        #
        # @api public
        module EDirectory
          NETWARE_SERVERS = '(objectClass=ncpServer)'
          NETWARE_VOLUMES = '(objectClass=volume)'
          ZEN_APPLICATION = '(objectClass=appApplication)'

          # @see https://confluence.atlassian.com/kb/how-to-write-ldap-search-filters-792496933.html
          # dn_part_match = '(|(ou:dn:=Chicago)(ou:dn:=Miami)))'.freeze
        end
      end
    end
  end
end

ROM.plugins do
  adapter :ldap do
    register :e_directory, ROM::Plugins::Relation::LDAP::EDirectory, type: :relation
  end
end
