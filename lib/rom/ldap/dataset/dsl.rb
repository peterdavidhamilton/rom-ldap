module ROM
  module LDAP
    class Dataset
      # Query interface
      #
      # @api public
      module DSL
        def equals(args)
          @criteria << [:con_or, *array(args)]
          self
        end
        alias where equals

        def unequals(args)
          @criteria << [:con_not, [:con_or, *array(args)]]
          self
        end

        def present(attribute)
          @criteria << [:op_equal, attribute, :wildcard]
          self
        end
        alias has present
        alias exists present

        def missing(attribute)
          @criteria << [:con_not, [:op_equal, attribute, :wildcard]]
          self
        end
        alias hasnt missing

        def gt(args)
          @criteria << [:op_gt, *args.to_a.first]
          self
        end

        def gte(args)
          @criteria << [:op_gt_eq, *args.to_a.first]
          self
        end
        alias above gte

        def lt(args)
          # @criteria << [:op_lt, *args.to_a[0]]
          @criteria << args.to_a.unshift(:op_lt)
          self
        end

        def lte(args)
          @criteria << [:op_lt_eq, *args.to_a.first]
          self
        end
        alias below lte

        def begins(args)
          @criteria << wildcard(args, right: WILDCARD)
          self
        end
        # alias starts begins

        def ends(args)
          @criteria << wildcard(args, left: WILDCARD)
          self
        end
        # alias suffix ends

        def contains(args)
          @criteria << wildcard(args, left: WILDCARD, right: WILDCARD)
          self
        end
        alias matches contains

        def excludes(args)
          @criteria << [:con_not, wildcard(args, left: WILDCARD, right: WILDCARD)]
          self
        end

        def within(args)
          @criteria << [:con_and, range(args)]
          self
        end
        alias between within

        def outside(args)
          @criteria << [:con_not, [:con_and, range(args)]]
          self
        end

        private

        # def save(expression)
        #   @criteria = expression if @criteria.empty?
        #   @criteria << expression
        # end

        def array(args)
          attribute, values = args.to_a.first

          Array(values).map do |value|
            [:op_equal, attribute, escape(value)]
          end
        end

        def wildcard(args, left: EMPTY_STRING, right: EMPTY_STRING)
          attribute, value = args.to_a.first
          value = left + escape(value) + right
          [ :op_equal, attribute, value ]
        end

        def range(args)
          attribute, range = args.to_a.first

          lower, *rest, upper = range.to_a
          # lower = range.to_a.first
          lower = [:op_gt_eq, attribute, lower]

          # upper = range.to_a.last
          upper = [:op_lt_eq, attribute, upper]

          [lower, upper]
        end

        def escape(value)
          string = Types::Coercible::String[value]
          string.gsub(ESCAPE_REGEX) { |char| '\\' + ESCAPES[char] }
        end
      end
    end
  end
end
