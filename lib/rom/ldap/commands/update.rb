# encoding: utf-8
# frozen_string_literal: true

module ROM
  module Ldap
    module Commands
      class Update < ROM::Commands::Update
        adapter :ldap

        # TODO: Remove Array.wrap now decoupled from Active Support
        def execute(tuples)
          Array.wrap(tuples).each do |tuple|
            # :remove if v nil
            # :add if v present
            ops = tuple.except(:dn).map { |k, v| [:add, k, v] }

            relation.update(tuple[:dn], ops)
          end
        end
      end
    end
  end
end
