module ROM
  module Ldap
    module Commands
      class Delete < ROM::Commands::Delete
        adapter :ldap

        # TODO: Remove Array.wrap now decoupled from Active Support
        def execute(tuples)
          binding.pry

          Array.wrap(tuples).each do |tuple|
            relation.delete(tuple[:dn])
          end
        end
      end
    end
  end
end
