# frozen_string_literal: true

module ROM
  module LDAP
    #
    # RedHat 389DS Extension
    #
    # @api private
    module ThreeEightNine
      # @api public
      def netscapemdsuffix
        root.first('netscapemdsuffix')
      end
    end
  end
end
