module ROM
  module Ldap
    module Commands
      class Create < ROM::Commands::Create
        adapter :ldap

        def execute(tuples)
          [tuples].flatten.each { |tuple| relation.create(tuple) }
        end
      end
    end
  end
end
