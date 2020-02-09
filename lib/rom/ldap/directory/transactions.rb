module ROM
  module LDAP
    class Directory

      # https://ldapwiki.com/wiki/Lightweight%20Directory%20Access%20Protocol%20%28LDAP%29%20Transactions
      # https://tools.ietf.org/html/rfc5805
      # https://ldapwiki.com/wiki/EDirectory%20LDAP%20Transaction
      #
      module Transactions
        # @example
        #   directory.transaction(opts) { yield(self) }
        #
        # @todo Transactions WIP
        #
        # @api public
        def transaction(_opts)
          # binding.pry

          # OID[:transaction_start_request]
          # OID[:transaction_spec_request]
          # OID[:transaction_end_request]

          yield()
        end
      end

    end
  end
end
