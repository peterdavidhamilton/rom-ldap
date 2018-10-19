# @see https://tools.ietf.org/html/rfc5805
#
module ROM
  module LDAP
    # @api private
    class Transaction < ::ROM::Transaction
      attr_reader :directory
      private :directory

      def initialize(directory)
        @directory = directory
      end

      def run(opts = EMPTY_HASH)
        directory.transaction(opts) { yield(self) }
      rescue ::ROM::Transaction::Rollback
        # noop
      end
    end
  end
end
