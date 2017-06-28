module ROM
  module Ldap
    module Commands
      class Create < ROM::Commands::Create
        adapter :ldap

        # TODO: Remove Array.wrap now decoupled from Active Support
        def execute(tuples)
          Array.wrap(tuples).each do |tuple|
            dn = create_dn(tuple[:uid])
            binding.pry
            relation.create(dn, tuple)
          end
        end

        # TODO: create Distinguishing Name
        # creates a DN based on UID and BASE
        def create_dn(uid)
          "uid=#{uid},#{relation.base}"
        end
      end
    end
  end
end
