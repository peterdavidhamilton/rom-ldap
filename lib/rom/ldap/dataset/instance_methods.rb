module ROM
  module LDAP
    class Dataset
      module InstanceMethods
        # True if password binds for the filtered dataset
        #
        # @param password [String]
        #
        # @return [Boolean]
        #
        # @api public
        def authenticated?(password)
          directory.bind_as(filter: query, password: password)
        end

        # @return [Boolean]
        #
        # @api public
        def any?
          each.any?
        end

        # @return [Integer]
        #
        # @api public
        def count
          each.size
        end

        # Unrestricted count of every entry under the base with base entry deducted.
        #
        # @return [Integer]
        #
        # @api public
        def total
          directory.base_total - 1
        end

        # Find by Distinguished Name
        #
        # @param dn [String]
        #
        # @return [Array<Entity>]
        #
        # @api public
        def fetch(dn)
          directory.by_dn(dn)
        end

        # Interface to Directory#add
        #
        # @param tuple [Hash]
        #
        # @return [Boolean]
        #
        # @api public
        def add(tuple)
          directory.add(tuple)
        end

        # Interface to Directory#modify
        #
        # @param entries [Array<Entity>] Entries to modify received from command.
        #
        # @param tuple [Changeset, Hash] Modification params
        #
        # @api public
        def modify(entries, tuple)
          entries.map { |e| directory.modify(*e[:dn], tuple) }
        end

        # Interface to Directory#delete
        #
        # @api public
        def delete(entries)
          entries.map { |e| directory.delete(*e[:dn]) }
        end

        # OPTIMIZE: dataset string export formats call method on entity in the same way
        # FIXME: JSON and YAML need to output datasets not individual entities.

        # Output the dataset as an LDIF string
        #
        # @return [String]
        #
        # @api public
        def to_ldif
          each.map(&:to_ldif).to_a.join
        end

        # Output the dataset as JSON
        #
        # @return [String]
        #
        # @api public
        def to_json
          each.map(&:to_json).to_a.join
        end

        # Output the dataset as YAML
        #
        # @return [String]
        #
        # @api public
        def to_yaml
          each.map(&:to_yaml).to_a.join
        end
      end
    end
  end
end
