# encoding: utf-8
# frozen_string_literal: true

module ROM
  module Ldap
    module Commands
      class Update < ROM::Commands::Update

        adapter :ldap

        def execute(tuples)
          Array.wrap(tuples).each do |tuple|

            tuple.merge!(relation.default_attrs){|key, oldval, newval| oldval }

            relation.update(tuple[:dn], tuples.except(:dn))
          end
        end

      end
    end
  end
end
