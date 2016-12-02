# encoding: utf-8
# frozen_string_literal: true

module ROM
  module Ldap
    module Commands
      class Create < ROM::Commands::Create

        adapter :ldap

        # dn: 'uid=unique,ou=users,dc=test', uid: 'blaster', givenname: 'essential', sn: 'master', cn:  'help'

        # insert_tuples = with_input_tuples(tuples) do |tuple|
        #   attributes = input[tuple]
        #   validator.call(attributes)
        #   attributes.to_h
        # end

        def execute(tuples)
          Array.wrap(tuples).each do |tuple|

            tuple.merge!(relation.default_attrs){|key, oldval, newval| oldval }

            relation.create(tuple[:dn], tuple.except(:dn))
          end
        end

      end
    end
  end
end
