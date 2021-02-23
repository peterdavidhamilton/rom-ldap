# frozen_string_literal: true

require 'oj'

module ROM
  module LDAP
    module OptimisedJSON
      # Replace #to_json
      #
      # @param _opts [Mixed] compatibility with JSON.generate
      #
      # @return [String]
      #
      # @example
      #   relation.to_json
      #
      # @api public
      def to_json(_opts = nil)
        Oj.generate(export)
      end
    end

    Relation.include OptimisedJSON
  end
end
