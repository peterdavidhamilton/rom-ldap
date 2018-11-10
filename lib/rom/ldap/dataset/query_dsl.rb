module ROM
  module LDAP
    class Dataset
      # AST Query Interface
      #
      # @api public
      module QueryDSL
        # Equality filter aliased as 'where'.
        #
        # @example
        #   relation.where(uid: 'pete')
        #   relation.where(uid: %w[pete leanda])
        #   relation.where(uid: 'leanda', sn: 'hamilton')
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
        # @api public
        def unequal(args)
          chain(:con_not, array_dsl(args))
        end
        alias where_not unequal

        # Presence filter aliased as 'has'.
        #
        # @example
        #   relation.present(:uid)
        #   relation.has(:mail)
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
        # @api public
        def missing(attribute)
          chain(:con_not, [:op_eql, attribute, :wildcard])
        end
        alias hasnt missing

        # Greater than filter
        #
        # @api public
        def gt(args)
          chain(:con_not, [:op_lte, *args.to_a[0]])
        end
        alias above gt

        # Less than filter
        #
        # @api public
        def lt(args)
          chain(:con_not, [:op_gte, *args.to_a[0]])
        end
        alias below lt

        # Greater than or equal filter
        #
        # @api public
        def gte(args)
          chain(:op_gte, *args.to_a[0])
        end

        # Less than or equal filter
        #
        # @api public
        def lte(args)
          chain(:op_lte, *args.to_a[0])
        end

        # Starts with filter
        #
        # @api public
        def begins(args)
          chain(*match_dsl(args, right: WILDCARD))
        end

        # Ends with filter
        #
        # @api public
        def ends(args)
          chain(*match_dsl(args, left: WILDCARD))
        end

        def contains(args)
          chain(*match_dsl(args, left: WILDCARD, right: WILDCARD))
        end
        alias matches contains

        # negate #contains
        #
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




                    def binary_equal(args)
                      chain(:op_bineq, *args.to_a[0])
                    end

                    def approx(args)
                      chain(:op_prx, *args.to_a[0])
                    end

                    def bitwise(args)
                      chain(:op_ext, *args.to_a[0])
                    end






        private

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
        # @options :left [String] prepended to value.
        #
        # @options :right [String] appended to value.
        #
        # @return [Array]
        #
        # @example
        #   match_dsl(bar: 'foo', left: '*', right: '*')
        #       => [:op_eql, :bar, '*foo*']
        #
        # @api private
        def match_dsl(args, left: EMPTY_STRING, right: EMPTY_STRING)
          attribute, value = args.to_a[0]
          value = left.to_s + escape(value) + right.to_s
          [:op_eql, attribute, value]
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
