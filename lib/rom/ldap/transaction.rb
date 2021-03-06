# frozen_string_literal: true

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

      def run(opts = EMPTY_OPTS)
        directory.transaction(opts) { yield(self) }
      rescue ::ROM::Transaction::Rollback
        # noop
      end

    end
  end
end
