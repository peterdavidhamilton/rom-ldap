# https://ldapwiki.com/wiki/Lightweight%20Directory%20Access%20Protocol%20%28LDAP%29%20Transactions
# https://tools.ietf.org/html/rfc5805
# 1.3.6.1.1.21.1
# 1.3.6.1.1.21.3 ?
module ROM
  module LDAP
    class Directory
      module Transactions

        # @example
        #   directory.transaction(opts) { yield(self) }
        #
        # @todo Transactions WIP
        #
        # @api public
        def transaction(_opts)
          yield()
        end


      end
    end
  end
end
