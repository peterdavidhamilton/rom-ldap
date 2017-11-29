module ROM
  module LDAP
    module Commands
      class Create < ROM::Commands::Create
        adapter :ldap

        def execute(tuples)
          Array(tuples).each { |tuple| relation.insert(tuple) }
        end
      end
    end
  end
end
