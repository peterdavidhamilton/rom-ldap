module ROM
  module LDAP
    class Dataset
      # AST Query Interface
      #
      # @api public
      module DSL
        # Equality filter aliased as 'where'.
        #
        # @example
        #   relation.where(uid: 'pete')
        #   relation.where(uid: %w[pete leanda])
        #
        # @api public
        def equals(args)
          chain(*array_arguments(args))
        end
        alias where equals

        # Inequality filter aliased as '?'. Inverse of 'equals'.
        #
        # @example
        #   relation.unequals(uid: 'pete')
        #   relation.unequals(uid: %w[pete leanda])
        #
        # @api public
        def unequals(args)
          chain(:con_not, array_arguments(args))
        end

        # Presence filter aliased as 'has', 'exists'.
        #
        # @example
        #   relation.present(:uid)
        #   relation.has(:mail)
        #
        # @api public
        def present(attribute)
          chain(:op_eq, attribute, :wildcard)
        end
        alias has present
        alias exists present

        # Absence filter aliased as 'hasnt'. Inverse of 'present'.
        #
        # @example
        #   relation.missing(:uid)
        #   relation.hasnt(:mail)
        #
        # @api public
        def missing(attribute)
          chain(:con_not, [:op_eq, attribute, :wildcard])
        end
        alias hasnt missing

        def gt(args)
          chain(:con_not, [:op_lte, *args.to_a[0]])
        end
        alias above gt

        def lt(args)
          chain(:con_not, [:op_gte, *args.to_a[0]])
        end
        alias below lt

        def gte(args)
          chain(:op_gte, *args.to_a[0])
        end

        def lte(args)
          chain(:op_lte, *args.to_a[0])
        end

        def begins(args)
          chain(*wildcard_arguments(args, right: WILDCARD))
        end
        # alias starts begins

        def ends(args)
          chain(*wildcard_arguments(args, left: WILDCARD))
        end
        # alias suffix ends

        def contains(args)
          chain(*wildcard_arguments(args, left: WILDCARD, right: WILDCARD))
        end
        alias matches contains

        def excludes(args)
          chain(:con_not, wildcard_arguments(args, left: WILDCARD, right: WILDCARD))
        end

        def within(args)
          chain(:con_and, range_arguments(args))
        end
        alias between within

        def outside(args)
          chain(:con_not, [:con_and, range_arguments(args)])
        end

        private

        # Update the criteria
        #
        # @api private
        def chain(*exprs)
          @criteria.unshift(*exprs)
          self
        end

        # Handle potential arrays of arguments with an 'either or join'
        #
        # @param args [Array]
        #
        # @return [Array]
        #
        # @api private
        def array_arguments(args)
          attribute, values = args.to_a[0]
          exprs = Array(values).map { |val| [:op_eq, attribute, escape(val)] }
          exprs.size >= 2 ? [:con_or, exprs] : exprs.flatten
        end

        # Process values >= 1
        #
        # @param args [Array]
        #
        # @options :left [String] prepended to value - used for wildcard
        # @options :right [String] appended to value - used for wildcard
        #
        # @return [Array]
        #
        # @api private
        def wildcard_arguments(args, left: EMPTY_STRING, right: EMPTY_STRING)
          attribute, value = args.to_a[0]
          value = left + escape(value) + right
          [:op_eq, attribute, value]
        end

        # Process values >= 1
        #
        # @param args [Array]
        #
        # @return [Array]
        #
        # @api private
        def range_arguments(args)
          attribute, range = args.to_a[0]
          lower, *rest, upper = range.to_a

          lower = [:op_gte, attribute, lower]
          upper = [:op_lte, attribute, upper]

          [lower, upper]
        end

        # Escape "(, ), \, *, null" characters
        #
        # @api private
        def escape(value)
          value.to_s.gsub(ESCAPE_REGEX) { |char| '\\' + ESCAPES[char] }
        end
      end
    end
  end
end
