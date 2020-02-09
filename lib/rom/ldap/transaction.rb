module ROM
  module LDAP
    # Work in progress
    #
    # @see https://tools.ietf.org/html/rfc5805
    #
    # @api private
    class Transaction < ::ROM::Transaction

      attr_reader :directory
      private :directory

      def initialize(directory)
        @directory = directory
      end

      # rubocop:disable Lint/SuppressedException
      def run(opts = EMPTY_OPTS)
        directory.transaction(opts) { yield(self) }
      rescue ::ROM::Transaction::Rollback
        # noop
      end
      # rubocop:enable Lint/SuppressedException

    end
  end
end
