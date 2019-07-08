# https://tools.ietf.org/html/rfc5805
#
module ROM
  module LDAP
    class Directory
      module Transactions

        # directory.transaction(opts) { yield(self) }
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
