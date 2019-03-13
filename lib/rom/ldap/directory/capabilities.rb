module ROM
  module LDAP
    class Directory
      #
      # Convenience predicates
      #
      module Capabilities

        # Named capabilities
        #
        # @see rom/ldap/constants.rb
        #
        # @return [Array<Symbol>]
        #
        # @api public
        def capabilities
          @capabilities ||= CONTROLS.invert.values_at(*supported_controls).freeze
        end

        # Is the server able to order the entries.
        #
        # @return [Boolean]
        #
        # @api public
        def sortable?
          capabilities.include?(:sort_response)
        end

        # @return [Boolean]
        #
        # @api public
        def pageable?
          capabilities.include?(:paged_results)
        end

        # @return [Boolean]
        #
        # @api public
        def chainable?
          capabilities.include?(:matching_rule_in_chain)
        end

        # @return [Boolean]
        #
        # @api public
        def pruneable?
          capabilities.include?(:delete_tree)
        end

        # @return [Boolean]
        #
        # @api public
        def bitwise?
          capabilities.include?(:matching_rule_bit_and) &&
            capabilities.include?(:matching_rule_bit_or)
        end

        # @return [Boolean]
        #
        # @api public
        def i18n?
          capabilities.include?(:language_tag_options) &&
            capabilities.include?(:language_range_options)
        end
      end
    end
  end
end
