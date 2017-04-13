# encoding: utf-8
# frozen_string_literal: true

module ROM
  module Ldap
    module Commands
      class Delete < ROM::Commands::Delete
        adapter :ldap

        # TODO: Remove Array.wrap now decoupled from Active Support
        def execute(tuples)
          Array.wrap(tuples).each do |tuple|
            relation.delete(tuple[:dn])
          end
        end
      end
    end
  end
end
