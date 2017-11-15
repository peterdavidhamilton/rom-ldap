module ROM
  module LDAP
    class Dataset
      # Query interface
      #
      # @api public
      module DSL
        def equals(args)
          attribute, values = args.to_a.first

          # array of values means "|" join
          exps = Array(values).map do |value|
            [:op_equal, attribute, escape(value)]
          end

          @criteria << [:con_or, exps]

          self
        end
        alias where equals

        def unequals(args)
          attribute, values = args.to_a.first

          Array(values).each do |value|
            @criteria << [:con_not, [:op_equal, attribute, escape(value)]]
          end

          self
        end

        def present(attribute)
          @criteria << [:op_equal, attribute, :wildcard]
          self
        end
        alias has present
        alias exists present

        def missing(args)
          attribute = args.to_a.first
          @criteria << [:con_not, [:op_equal, attribute, :wildcard]]
          self
        end
        alias hasnt missing

        def gt(args)
          @criteria << [:op_gt, *args.to_a.first]
          self
        end
        alias above gt

        def gte(args)
          @criteria << [:op_gt_eq, *args.to_a.first]
          self
        end

        def lt(args)
          @criteria << [:op_lt, *args.to_a.first]
          self
        end
        alias below lt

        def lte(args)
          @criteria << [:op_lt_eq, *args.to_a.first]
          self
        end

        def begins(args)
          attribute, value = args.to_a.first
          @criteria << [
            :op_equal,
            attribute,
            escape(value) + WILDCARD
          ]
          self
        end
        # alias starts begins

        def ends(args)
          attribute, value = args.to_a.first
          @criteria << [
            :op_equal,
            attribute,
            WILDCARD + escape(value)
          ]
          self
        end
        # alias suffix ends

        def contains(args)
          attribute, value = args.to_a.first
          @criteria << [
            :op_equal,
            attribute,
            WILDCARD + escape(value) + WILDCARD
          ]
          self
        end
        alias matches contains

        def exclude(args)
          @criteria << [:con_not, contains(args)]
          self
        end

        def within(args)
          attribute, range = args.to_a.first

          lower = range.to_a.first
          lower = [:op_gt_eq, attribute, lower]

          upper = range.to_a.last
          upper = [:op_lt_eq, attribute, upper]

          @criteria << [:con_and, [lower, upper]]
          self
        end
        alias between within
        alias range within

        def outside(args)
          @criteria << [:con_not, within(args)]
          self
        end

        private

        def escape(value)
          string = Types::Coercible::String[value]
          string.gsub(ESCAPE_REGEX) { |char| '\\' + ESCAPES[char] }
        end
      end
    end
  end
end
