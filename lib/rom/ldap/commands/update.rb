module ROM
  module LDAP
    module Commands
      class Update < ROM::Commands::Update
        adapter :ldap

        after :finalize

        def execute(tuple)
          update(input[tuple].to_h)
        end

        private

        # @param tuples [Array<Hash>] update entries returned by directory
        #
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
