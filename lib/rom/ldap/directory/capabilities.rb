module ROM
  module LDAP
    class Directory
      #
      # Convenience predicates
      #
      module Capabilities

        def capabilities
          supported_controls.map { |oid| ::BER.lookup(:controls, oid) }.sort
        end

        # Is the server able to order the entries.
        #
        # @return [Boolean]
        #
        # @api public
        def sortable?
          # supported_controls.include?(SORT_RESPONSE)
          capabilities.include?(:sort_response)
          # or
          # ::BER.reverse_lookup(:controls, :sort_response)
        end

        # @return [Boolean]
        #
        # @api public
        def pageable?
          supported_controls.include?(PAGED_RESULTS)
        end

        # @return [Boolean]
        #
        # @api public
        def chainable?
          supported_controls.include?(MATCHING_RULE_IN_CHAIN)
        end

        # @return [Boolean]
        #
        # @api public
        def pruneable?
          supported_controls.include?(DELETE_TREE)
        end

        # @return [Boolean]
        #
        # @api public
        def bitwise?
          supported_controls.include?(MATCHING_RULE_BIT_AND) &&
            supported_controls.include?(MATCHING_RULE_BIT_OR)
        end

        # @return [Boolean]
        #
        # @api public
        def i18n?
          supported_controls.include?(LANGUAGE_TAG_OPTIONS) &&
            supported_controls.include?(LANGUAGE_RANGE_OPTIONS)
        end
      end
    end
  end
end
