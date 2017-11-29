module ROM
  module LDAP
    module Commands
      class Delete < ROM::Commands::Delete
        adapter :ldap

        def execute
          relation.delete
        end
      end
    end
  end
end
