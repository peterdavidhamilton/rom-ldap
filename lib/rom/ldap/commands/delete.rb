module ROM
  module Ldap
    module Commands
      class Delete < ROM::Commands::Delete
        adapter :ldap

        def execute
          # ldap.delete dn: 'uid=temp,ou=users,dc=test'

          binding.pry

          relation.each { |tuple| source.delete(tuple) }
        end
      end
    end
  end
end
