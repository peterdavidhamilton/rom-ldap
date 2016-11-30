# encoding: utf-8
# frozen_string_literal: true

module ROM
  module Ldap
    module Commands
      class Delete < ROM::Commands::Delete

        adapter :ldap

        def execute(tuples)
          tuples.each { |tuple| relation.delete(tuple[:dn]) }
        end
      end
    end
  end
end
