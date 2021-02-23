# frozen_string_literal: true

module ROM
  module LDAP
    class Dataset

      # AST Query Interface
      #
      # @api private
      module DSL
        # Invert the whole query
        #
        # @return [Dataset]
        def inverse
          with(criteria: [:con_not, criteria])
        end

        # Equality filter aliased as 'where'.
        #
        # @example
        #   relation.where(uid: 'Pietro')
        #   relation.where(uid: %w[Pietro Wanda])
        #   relation.where(uid: 'Pietro', sn: 'Maximoff')
        #
        # @param args [Hash]
        #
        # @return [Dataset]
        def equal(args)
          chain(*array_dsl(args))
        end

        # Antonym of 'equal'
        #
        # @example
        #   relation.unequal(uid: 'Pietro')
        #   relation.unequal(uid: %w[Pietro Wanda])
        #
        # @param args [Hash]
        #
        # @return [Dataset]
        def unequal(args)
          chain(:con_not, array_dsl(args))
        end

        # Presence filter aliased as 'has'.
        #
        # @example
        #   relation.present(:uid)
        #   relation.has(:mail)
        #
        # @param attribute [Symbol]
        #
        # @return [Dataset]
        def present(attribute)
          chain(:op_eql, attribute, :wildcard)
        end
        alias_method :has, :present

        # Absence filter aliased as 'hasnt'. Inverse of 'present'.
        #
        # @example
        #   relation.missing(:uid)
        #   relation.hasnt(:mail)
        #
        # @param attribute [Symbol]
        #
        # @return [Dataset]
        def missing(attribute)
          chain(:con_not, [:op_eql, attribute, :wildcard])
        end
        alias_method :hasnt, :missing

        # Greater than filter
        #
        # @param args [Hash]
        #
        # @return [Dataset]
        def gt(args)
          chain(:con_not, [:op_lte, *args.to_a[0]])
        end
        alias_method :above, :gt

        # Less than filter
        #
        # @param args [Hash]
        #
        # @return [Dataset]
        def lt(args)
          chain(:con_not, [:op_gte, *args.to_a[0]])
        end
        alias_method :below, :lt

        # Greater than or equal filter
        #
        # @param args [Hash]
        #
        # @return [Dataset]
        def gte(args)
          chain(:op_gte, *args.to_a[0])
        end

        # Less than or equal filter
        #
        # @param args [Hash]
        #
        # @return [Dataset]
        def lte(args)
          chain(:op_lte, *args.to_a[0])
        end

        # Starts with filter
        #
        # @param args [Hash]
        #
        # @return [Dataset]
        def begins(args)
          chain(*match_dsl(args, right: WILDCARD))
        end

        # Ends with filter
        #
        # @param args [Hash]
        #
        # @return [Dataset]
        def ends(args)
          chain(*match_dsl(args, left: WILDCARD))
        end

        # @param args [Hash]
        #
        # @return [Dataset]
        def contains(args)
          chain(*match_dsl(args, left: WILDCARD, right: WILDCARD))
        end
        alias_method :matches, :contains

        # negate #contains
        #
        # @param args [Hash]
        #
        # @return [Dataset]
        def excludes(args)
          chain(:con_not, match_dsl(args, left: WILDCARD, right: WILDCARD))
        end

        # @param args [Range]
        #
        # @return [Dataset]
        def within(args)
          chain(:con_and, cover_dsl(args))
        end
        alias_method :between, :within

        # negate #outside
        #
        # @param args [Range]
        #
        # @return [Dataset]
        def outside(args)
          chain(:con_not, [:con_and, cover_dsl(args)])
        end

        # @param args [Hash]
        #
        # @return [Dataset]
        def binary_equal(args)
          chain(:op_bineq, *args.to_a[0])
        end

        # @param args [Hash]
        #
        # @return [Dataset]
        def approx(args)
          chain(:op_prx, *args.to_a[0])
        end

        # @param args [Hash]
        #
        # @return [Dataset]
        def bitwise(args)
          chain(:op_ext, *args.to_a[0])
        end

        private

        # Update the criteria.
        #   If criteria already exist join with AND.
        #
        # @example
        #   chain(:op_eql, :uid,  "*foo*")
        #
        # @param exprs [Mixed] AST built by QueryDSL
        #
        # @return [Dataset]
        def chain(*exprs)
          if criteria.empty?
            with(criteria: exprs)
          else
            with(criteria: [:con_and, [criteria, exprs]])
          end
        end

        # Handle multiple criteria with an OR join.
        #   @see #chain for AND join.
        #
        # @param args [Hash]
        #
        # @return [Array] AST
        #
        # @example
        #   array_dsl(sn: 'Maximoff', gn: %w[Wanda Pietror])
        #   =>
        #       [ :con_or,
        #         [
        #           [ :op_eql, :sn, "Maximoff" ],
        #           [ :con_or,
        #             [
        #               [ :op_eql, :gn, "Wanda" ],
        #               [ :op_eql, :gn, "Pietror" ]
        #             ]
        #           ]
        #         ]
        #       ]
        #
        def array_dsl(args)
          expressions = args.map do |left, right|
            values = Array(right).map { |v| [:op_eql, left, escape(v)] }
            join_dsl(:con_or, values)
          end
          join_dsl(:con_or, expressions)

          # join_dsl(:con_or, [ match_dsl(args.map(&:to_a)) ])
          # join_dsl(:con_or, args.map { |arg| match_dsl([arg]) })
        end

        # Wrap criteria with a join operator.
        #
        # @param operator [Symbol] :con_or, :con_and
        #
        # @param ary [Array] [[op, left, right],[op, left, right]]
        def join_dsl(operator, ary)
          ary.size >= 2 ? [operator, ary] : ary.first
        end

        # Wrap criteria value with extra characters, used for wildcard
        #
        # @param args [Array]
        #
        # @option :left  [String] Prepended to value.
        # @option :right [String] Appended to value.
        #
        # @return [Array]
        #
        # @example
        #   match_dsl(bar: 'foo', left: '*', right: '*')
        #       => [:op_eql, :bar, '*foo*']
        #
        def match_dsl(args, left: EMPTY_STRING, right: EMPTY_STRING)
          expressions = args.map do |att, val|
            values = Array(val).map do |v|
              value = left.to_s + escape(v) + right.to_s
              [:op_eql, att, value]
            end

            join_dsl(:con_or, values)
          end
          join_dsl(:con_or, expressions)
        end

        #
        # @param args [Range,Array]
        #
        # @return [Array]
        def cover_dsl(args)
          attribute, range = args.to_a[0]
          lower, *_, upper = range.to_a

          lower = [:op_gte, attribute, lower]
          upper = [:op_lte, attribute, upper]

          [lower, upper]
        end

        # If any of the following special characters appear in the
        # search filter as literals, they must be escaped with a backslash.
        #
        # "(", ")", "\", ,"/" "*", "null"
        #
        # @param value [String, Integer]
        #
        # @return [String]
        def escape(value)
          value.to_s.gsub(ESCAPE_REGEX) { |char| '\\' + ESCAPES[char] }
        end
      end

    end
  end
end
