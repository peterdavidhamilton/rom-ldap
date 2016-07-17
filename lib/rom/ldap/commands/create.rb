module ROM
  module Ldap
    module Commands
      class Create < ROM::Commands::Create
        adapter :ldap

        def execute(tuples)

          # insert_tuples = with_input_tuples(tuples) do |tuple|
          #   attributes = input[tuple]
          #   validator.call(attributes)
          #   attributes.to_h
          # end

          binding.pry

          # with_input_tuples(tuples) do |tuple|

          Array.wrap(tuples).each do |tuple|

            # coerce tuple using mapper

            insert(dn: dn(tuple.uid), attributes: tuple.to_h)
          end
        end

        private

        # def insert(tuple)
        #   relation.directory.add(tuple)
        # end

        # should be done by a mapper - to preprocess
        def dn(uid)
          "uid=#{uid},ou=users,dc=test"
        end


        # Yields tuples for insertion or return an enumerator
        #
        # @api private
        # def with_input_tuples(tuples)
        #   input_tuples = Array([tuples]).flatten.map
        #   return input_tuples unless block_given?
        #   input_tuples.each { |tuple| yield(tuple) }
        # end

      end
    end
  end
end
