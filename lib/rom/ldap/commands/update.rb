module ROM
  module Ldap
    module Commands
      class Update < ROM::Commands::Update
        adapter :ldap

        # TODO: Remove Array.wrap now decoupled from Active Support
        def execute(tuples)
          binding.pry

          Array.wrap(tuples).each do |tuple|
            # :remove if v nil
            # :add if v present
            ops = tuple.except(:dn).map { |k, v| [:add, k, v] }

            relation.update(tuple[:dn], ops)
          end
        end
      end
    end
  end
end
