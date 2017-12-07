module ROM
  module LDAP
    module Commands
      class Update < ROM::Commands::Update
        adapter :ldap

        # use :schema

        after :finalize

        def execute(tuple)
          update(input[tuple].to_h)
        end

        private

        # Update entries returned by directory
        #
        # @param tuples [Array<Hash>]
        #
        # @api private
        def finalize(tuples, *)
          tuples.map { |t| relation.output_schema[t] }
        end

        def update(*args)
          relation.update(*args)
        end
      end
    end
  end
end
