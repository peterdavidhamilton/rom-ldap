# encoding: utf-8
# frozen_string_literal: true

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
          # coerce tuple using mapper

          Array.wrap(tuples).each do |tuple|
            relation.insert dn(tuple.uid), tuple.to_h
          end
        end

        private

        # should be done by a mapper - to preprocess
        def dn(uid)
          "uid=#{uid},ou=users,dc=test"
        end

      end
    end
  end
end
