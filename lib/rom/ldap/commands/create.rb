module ROM
  module LDAP
    module Commands
      class Create < ROM::Commands::Create

        adapter :ldap

        use :schema

        after :finalize

        # Pass tuple(s) to relation for insertion.
        #
        # @param tuples [Hash, Array<Hash>]
        #
        # @return [Array<Entry>]
        #
        # @api public
        def execute(tuples)
          Array([tuples]).flatten(1).map do |tuple|
            relation.insert(tuple)
          end
        end

        private

        # Output through relation output_schema
        #
        # @param entries [Array<Entry, FalseClass>]
        #
        # @api private
        def finalize(entries, *)
          entries.map { |t| relation.output_schema[t] }
        end

      end
    end
  end
end
