# frozen_string_literal: true

require 'yaml'
require 'json'
require 'rom/ldap/ldif'

module ROM
  module LDAP
    class Relation < ROM::Relation

      # LDIF, JSON, YAML and if loading extensions MsgPack and DSML.
      #
      module Exporting
        using LDIF

        # Export the relation as LDIF
        #
        # @return [String]
        #
        # @example
        #   relation.to_ldif
        #
        # @api public
        def to_ldif
          export.to_ldif
        end

        # Export the relation as JSON
        #
        # @param _opts [Mixed] compatibility with JSON.generate
        #
        # @return [String]
        #
        # @example
        #   relation.to_json
        #   JSON.generate(relation)
        #
        # @api public
        def to_json(_opts = nil)
          export.to_json
        end

        # Export the relation as YAML
        #
        # @return [String]
        #
        # @example
        #   relation.to_yaml
        #
        # @api public
        def to_yaml
          export.to_yaml
        end

        private

        # Serialize the selected dataset attributes in a formatted string.
        #
        # @example  i.e. YAML, JSON, LDIF, BINARY
        #   #=> relation.export.to_format
        #
        # @return [Hash, Array<Hash>]
        #
        # @api public
        def export
          dataset.respond_to?(:export) ? dataset.export : dataset
        end
      end

    end
  end
end
