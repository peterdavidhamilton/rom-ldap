# encoding: utf-8
# frozen_string_literal: true

module ROM
  module Ldap
    module Commands
      class Create < ROM::Commands::Create

        adapter :ldap

        def execute(tuples)
          Array.wrap(tuples).each do |tuple|
            dn = create_dn(tuple[:uid])
            relation.create(dn, tuple)
          end
        end

        # creates a DN based on UID and BASE
        def create_dn(uid)
          "uid=#{uid},#{relation.base}"
        end

      end
    end
  end
end
