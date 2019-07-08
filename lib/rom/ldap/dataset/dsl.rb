module ROM
  module LDAP
    class Dataset
      # AST Query Interface
      #
      # @api public
      module DSL

        # Invert the whole query
        #
        # @return [Dataset]
        #
        # @api public
        def inverse
          with(criteria: [:con_not, criteria])
        end

        # Equality filter aliased as 'where'.
        #
        # @example
        #   relation.where(uid: 'pete')
        #   relation.where(uid: %w[pete leanda])
        #   relation.where(uid: 'leanda', sn: 'hamilton')
        #
        # @return [Dataset]
        #
        # @api public
        def equal(args)
          chain(*array_dsl(args))
        end
        alias where equal

        # Antonym of 'equal'
        #
        # @example
        #   relation.unequal(uid: 'pete')
        #   relation.unequal(uid: %w[pete leanda])
        #
        # @return [Dataset]
        #
        # @api public
        def unequal(args)
          chain(:con_not, array_dsl(args))
        end

        # Presence filter aliased as 'has'.
        #
        # @example
        #   relation.present(:uid)
        #   relation.has(:mail)
        #
        # @return [Dataset]
        #
        # @api public
        def present(attribute)
          chain(:op_eql, attribute, :wildcard)
        end
        alias has present

        # Absence filter aliased as 'hasnt'. Inverse of 'present'.
        #
        # @example
        #   relation.missing(:uid)
        #   relation.hasnt(:mail)
        #
        # @return [Dataset]
        #
        # @api public
        def missing(attribute)
          chain(:con_not, [:op_eql, attribute, :wildcard])
        end
        alias hasnt missing

        # Greater than filter
        #
        # @return [Dataset]
        #
        # @api public
        def gt(args)
          chain(:con_not, [:op_lte, *args.to_a[0]])
        end
        alias above gt

        # Less than filter
        #
        # @return [Dataset]
        #
        # @api public
        def lt(args)
          chain(:con_not, [:op_gte, *args.to_a[0]])
        end
        alias below lt

        # Greater than or equal filter
        #
        # @return [Dataset]
        #
        # @api public
        def gte(args)
          chain(:op_gte, *args.to_a[0])
        end

        # Less than or equal filter
        #
        # @return [Dataset]
        #
        # @api public
        def lte(args)
          chain(:op_lte, *args.to_a[0])
        end

        # Starts with filter
        #
        # @return [Dataset]
        #
        # @api public
        def begins(args)
          chain(*match_dsl(args, right: WILDCARD))
        end

        # Ends with filter
        #
        # @return [Dataset]
        #
        # @api public
        def ends(args)
          chain(*match_dsl(args, left: WILDCARD))
        end

        # @return [Dataset]
        #
        # @api public
        def contains(args)
          chain(*match_dsl(args, left: WILDCARD, right: WILDCARD))
        end
        alias matches contains

        # negate #contains
        #
        # @return [Dataset]
        #
        # @api public
        def excludes(args)
          chain(:con_not, match_dsl(args, left: WILDCARD, right: WILDCARD))
        end

        # @param args [Range]
        #
        # @api public
        def within(args)
          chain(:con_and, cover_dsl(args))
        end
        alias between within

        # negate #outside
        #
        # @param args [Range]
        #
        # @api public
        def outside(args)
          chain(:con_not, [:con_and, cover_dsl(args)])
        end



        # @return [Dataset]
        #
        # @api public
        def binary_equal(args)
          chain(:op_eq, *args.to_a[0])
        end

        # @return [Dataset]
        #
        # @api public
        def approx(args)
          chain(:op_prx, *args.to_a[0])
        end

        # @return [Dataset]
        #
        # @api public
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
        #
        # @api private
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
        #   array_dsl(sn: 'hamilton', gn: %w[leanda peter])
        #   =>
        #       [ :con_or,
        #         [
        #           [ :op_eql, :sn, "hamilton" ],
        #           [ :con_or,
        #             [
        #               [ :op_eql, :gn, "leanda" ],
        #               [ :op_eql, :gn, "peter" ]
        #             ]
        #           ]
        #         ]
        #       ]
        #
        # @api private
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
        #
        # @api private
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
        # @api private
        def match_dsl(args, left: EMPTY_STRING, right: EMPTY_STRING)
          expressions = args.map do |att, val|
            values = Array(val).map { |v|
                        value = left.to_s + escape(v) + right.to_s
                        [:op_eql, att, value]
                      }

            join_dsl(:con_or, values)
          end
          join_dsl(:con_or, expressions)

          # attribute, value = args.to_a[0]
          # value = left.to_s + escape(value) + right.to_s
          # [:op_eql, attribute, value]
        end


        #
        #
        # @param args [Range,Array]
        #
        # @return [Array]
        #
        # @api private
        def cover_dsl(args)
          attribute, range = args.to_a[0]
          lower, *_, upper = range.to_a

          lower = [:op_gte, attribute, lower]
          upper = [:op_lte, attribute, upper]

          [lower, upper]
        end

        # If any of the following special characters must appear in the
        # search filter as literals, they must be escsped.
        #
        # "(", ")", "\", ,"/" "*", "null"
        #
        # @api private
        def escape(value)
          value.to_s.gsub(ESCAPE_REGEX) { |char| '\\' + ESCAPES[char] }
        end
      end
    end
  end
end
