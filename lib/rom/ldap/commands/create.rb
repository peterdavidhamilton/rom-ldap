module ROM
  module LDAP
    module Commands
      class Create < ROM::Commands::Create
        adapter :ldap

        # use :schema

        # Pass tuple(s) to relation for insertion.
        #
        # @param tuples [Hash, Array<Hash>]
        #
        # @api public
        def execute(tuples)
          [tuples].flatten.each { |tuple| relation.insert(tuple) }

          # Array([tuples]).flatten.map { |tuple|
          #   attributes = input[tuple]
          #   relation.insert(attributes.to_h)
          #   attributes
          # }.to_a
        end
      end
    end
  end
end
