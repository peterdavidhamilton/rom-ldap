module ROM
  module LDAP
    module Commands
      class Delete < ROM::Commands::Delete
        adapter :ldap

        def execute
          tuples = relation.dataset.entries
          relation.dataset.delete(tuples)
          tuples
        end
      end
    end
  end
end
