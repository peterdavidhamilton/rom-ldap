# frozen_string_literal: true

module ROM
  module LDAP
    module Commands
      class Update < ROM::Commands::Update

        adapter :ldap

        use :schema

        after :finalize

        def execute(tuple)
          update(input[tuple].to_h)
        end

        private

        #
        # @param entries [Array<Directory::Entry>]
        #
        # @api private
        def finalize(entries, *)
          entries.map { |t| relation.output_schema[t] }
        end

        def update(*args)
          relation.update(*args)
        end

      end
    end
  end
end
