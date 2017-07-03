module ROM
  module Ldap
    module Commands
      class Update < ROM::Commands::Update
        adapter :ldap

        after :finalize

        def execute(tuple)
          update(input[tuple].to_h)
        end

        private

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
