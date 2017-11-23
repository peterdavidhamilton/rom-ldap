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
        # @param dn [String, Array<String>]
        #
        # @return [Array<Entity>]
        #
        # @api public
        def fetch(dn)
          Array(dn).flat_map { |dn| directory.by_dn(dn) }
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

        # Handle different string output formats.
        #
        # @return [String]
        #
        # @api
        def export(format)
          case format
          when :ldif then each.map(&:to_ldif).to_a.join
          when :json then each.map(&:export).to_a.to_json
          when :yaml then each.map(&:export).to_a.to_yaml
          else
            raise 'unknown LDAP dataset export format'
          end
        end
      end
    end
  end
end
