# user_repo = UserRepo.new(rom)
# user      = user_repo.create(name: "Jane")
# changeset = user_repo.changeset(user.id, name: "Jane Doe")
# changeset.diff?         # => true
# changeset.diff          # => {name: "Jane Doe"}
# user_repo.update(user.id, changeset)
# user_repo.delete(user.id)

module ROM
  module Ldap
    module Commands
      class Update < ROM::Commands::Update
        adapter :ldap

        # TODO: Remove Array.wrap now decoupled from Active Support
        def execute(tuples)
          binding.pry

          # Array([tuples]).flatten

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
