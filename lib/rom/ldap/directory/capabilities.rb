module ROM
  module LDAP
    class Directory
      module Capabilities
        private

        # @return [Boolean]
        #
        # @api private
        def sortable?
          supported_controls.include?(SORT_RESPONSE)
        end

        # @return [Boolean]
        #
        # @api private
        def pageable?
          supported_controls.include?(PAGED_RESULTS)
        end

        # @return [Boolean]
        #
        # @api private
        def chainable?
          supported_controls.include?(MATCHING_RULE_IN_CHAIN)
        end

        # @return [Boolean]
        #
        # @api private
        def pruneable?
          supported_controls.include?(DELETE_TREE)
        end

        # @return [Boolean]
        #
        # @api private
        def bitwise?
          supported_controls.include?(MATCHING_RULE_BIT_AND) &&
          supported_controls.include?(MATCHING_RULE_BIT_OR)
        end

      end
    end
  end
end
