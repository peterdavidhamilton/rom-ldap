module ROM
  module LDAP
    module Commands
      class Create < ROM::Commands::Create
        adapter :ldap

        def execute(tuples)
          # Array([tuples]).flatten
          [tuples].flatten.each { |tuple| relation.create(tuple) }
        end
      end
    end
  end
end
