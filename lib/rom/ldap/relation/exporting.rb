module ROM
  module LDAP
    class Relation < ROM::Relation
      module Exporting

        # Serialize the selected dataset attributes in a formatted string.
        # Calls the method on the Directory::Entry or array of Entries.
        #
        # @example
        #   #=> relation.export(:to_format)
        #
        # @return [String] i.e. YAML, JSON, LDIF
        #
        # @api public
        def export(format)
          raise 'The dataset is no longer a Dataset class' unless dataset.is_a?(Dataset)
          dataset.export(format: format, keys: schema.to_h.keys)
        end

        # Export the relation as LDIF
        #
        # @return [String]
        #
        # @example
        #   relation.to_ldif
        #
        # @api public
        def to_ldif
          export(:to_ldif)
        end

        # Export the relation as JSON
        #
        # @return [String]
        #
        # @example
        #   relation.to_json
        #
        # @api public
        def to_json
          export(:to_json)
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
          export(:to_yaml)
        end

        # Export the relation as MessagePack
        #
        # @return [String]
        #
        # @example
        #   relation.to_yaml
        #
        # @api public
        def to_msgpack
          export(:to_msgpack)
        end

      end
    end
  end
end
