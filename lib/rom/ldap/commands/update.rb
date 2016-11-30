# encoding: utf-8
# frozen_string_literal: true

module ROM
  module Ldap
    module Commands
      class Update < ROM::Commands::Update

        adapter :ldap

        def execute(tuples)
          # ldap.delete_attribute 'uid=diradmin,ou=users,dc=test', :mail
          # ldap.add_attribute 'uid=diradmin,ou=users,dc=test', :mail, 'test@thing.com'
          # ldap.replace_attribute dn, :mail, "newmailaddress@example.com"

          # dn = "uid=example,ou=users,dc=test"
          # ops = [
          #   [:add, :mail, "aliasaddress@example.com"],
          #   [:replace, :mail, ["newaddress@example.com", "newalias@example.com"]],
          #   [:delete, :sn, nil] # sn attribute must exist
          # ]

          # ldap.modify dn: dn, operations: ops


          tuples.each do |tuple|
            relation.edit(tuple[:dn], tuples.except(:dn))
          end

        end
      end
    end
  end
end
