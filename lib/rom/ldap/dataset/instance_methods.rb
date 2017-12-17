module ROM
  module LDAP
    class Dataset
      module InstanceMethods

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
        # @param tuple [Changeset, Hash] Modification params
        #
        # @return [Array<Directory::Entry, Boolean>]
        #
        # @api public
        def modify(tuple)
          entries.map { |e| directory.modify(e.dn, tuple) }
        end

        # Interface to Directory#delete
        #
        # @return [Array<Directory::Entry, Boolean>]
        #
        # @api public
        def delete
          entries.map { |e| directory.delete(e.dn) }
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
