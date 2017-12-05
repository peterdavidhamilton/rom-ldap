module ROM
  module LDAP
    module Commands
      class Create < ROM::Commands::Create
        adapter :ldap

        # Pass tuple(s) to relation for insertion.
        #
        # @param tuples [Hash, Array<Hash>]
        #
        # @api public
        def execute(tuples)
          [tuples].flatten.each { |tuple| relation.insert(tuple) }
        end
      end
    end
  end
end
