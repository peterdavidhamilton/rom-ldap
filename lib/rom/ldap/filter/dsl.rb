module ROM
  module LDAP
    module Filter
      module DSL
        def equals(args)
          attribute, value = args.to_a.flatten
          @criteria << [:op_equal, attribute, escape(value)]
          self
        end
        alias where equals

        def unequals(args)
          attribute, value = args.to_a.flatten
          @criteria << [:con_not, [:op_equal, attribute, escape(value)]]
          self
        end

        def present(attribute)
          @criteria << [:op_equal, attribute, :wildcard]
          self
        end
        alias has present
        alias exists present

        def missing(args)
          attribute = args.to_a.flatten
          @criteria << [:con_not, [:op_equal, attribute, :wildcard]]
          self
        end
        alias hasnt missing

        def gt(args)
          @criteria << [:op_gt, *args.to_a.flatten]
          self
        end
        alias above gt

        def gte(args)
          @criteria << [:op_gt_eq, *args.to_a.flatten]
          self
        end

        def lt(args)
          @criteria << [:op_lt, *args.to_a.flatten]
          self
        end
        alias below lt

        def lte(args)
          @criteria << [:op_lt_eq, *args.to_a.flatten]
          self
        end

        def begins(args)
          attribute, value = args.to_a.flatten
          @criteria << [
            :op_equal,
            attribute,
            escape(value) + WILDCARD
          ]
          self
        end
        alias prefix begins

        def ends(args)
          attribute, value = args.to_a.flatten
          @criteria << [
            :op_equal,
            attribute,
            WILDCARD + escape(value)
          ]
          self
        end
        alias suffix ends

        def contains(args)
          attribute, value = args.to_a.flatten
          @criteria << [
            :op_equal,
            attribute,
            WILDCARD + escape(value) + WILDCARD
          ]
          self
        end
        alias matches contains

        def exclude(args)
          attribute, value = args.to_a.flatten
          @criteria << [
            :con_not, [
              :op_equal,
              attribute,
              WILDCARD + escape(value) + WILDCARD
            ]
          ]
          self
        end

        def within(args)
          attribute, range = args.to_a.flatten
          lower, upper = range.to_a.first, range.to_a.last
          @criteria << [
            :con_and, [
              [:op_gt_eq, attribute, lower], [:op_lt_eq, attribute, upper]
            ]
          ]
          self
        end
        alias between within
        alias range within

        def outside(args)
          attribute, range = args.to_a.flatten
          lower, upper = range.to_a.first, range.to_a.last
          @criteria << [
            :con_not, [
              :con_and, [
                [:op_gt_eq, attribute, lower], [:op_lt_eq, attribute, upper]
              ]
            ]
          ]
          self
        end

        private

        ESCAPES = {
          "\0" => '00', # NUL      = %x00 ; null character
          '*'  => '2A', # ASTERISK = %x2A ; asterisk (WILDCARD)
          '('  => '28', # LPARENS  = %x28 ; left parenthesis ("(")
          ')'  => '29', # RPARENS  = %x29 ; right parenthesis (")")
          '\\' => '5C', # ESC      = %x5C ; esc (or backslash) ("\")
        }.freeze

        ESCAPE_REGEX = Regexp.new('[' + ESCAPES.keys.map { |e| Regexp.escape(e) }.join + ']')

        def escape(string)
          string.gsub(ESCAPE_REGEX) { |char| '\\' + ESCAPES[char] }
        end

      end
    end
  end
end
