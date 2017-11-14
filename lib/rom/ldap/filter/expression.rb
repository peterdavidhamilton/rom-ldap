require 'dry-types'
require 'dry-initializer'
require 'rom/ldap/filter/expression/encoder'

module ROM
  module LDAP
    module Filter
      # @api private
      class Expression

        extend Dry::Initializer

        param :op, type: Dry::Types['strict.symbol']
        param :left
        param :right, optional: true

        #
        # Constructors
        #
        def &(other)
          self.class.new(:con_and, self, other)
        end

        def |(other)
          self.class.new(:con_or, self, other)
        end

        def ~@
          self.class.new(:con_not, self, nil)
        end

        def to_raw_rfc2254
          case op
          when :con_not   then        "!(#{left}=#{right})"
          when :op_equal, :bineq then "#{left}=#{right}"
          when :op_ext    then        "#{left}:=#{right}"
          when :op_prox   then        "#{left}~=#{right}"
          when :op_gt_eq  then        "#{left}>=#{right}"
          when :op_gt     then        "#{left}>#{right}"
          when :op_lt_eq  then        "#{left}<=#{right}"
          when :op_lt     then        "#{left}<#{right}"
          when :con_and   then        "&(#{left.to_raw_rfc2254})(#{right.to_raw_rfc2254})"
          when :con_or    then        "|(#{left.to_raw_rfc2254})(#{right.to_raw_rfc2254})"
          when :con_not   then        "!(#{left.to_raw_rfc2254})"
          end
        end

        def to_rfc2254
          "(#{to_raw_rfc2254})"
        end

        alias to_s to_rfc2254

        def inspect
          %(<##{self.class} op=#{op} left=#{left} right=#{right}>)
        end

        def to_ber
          Encoder.new(op, left, right).call
        end

        # @see [Filter::Expression::Decoder]
        #
        def execute(&block)
          binding.pry

          case op
          when :op_equal
            if right == WILDCARD
              yield :present, left
            elsif right.index WILDCARD
              yield(:substrings, left, right)
            else
              yield(:equalityMatch, left, right)
            end
          when :op_gt_eq
            yield(:greaterOrEqual, left, right)
          when :op_lt_eq
            yield(:lessOrEqual, left, right)
          when :con_or, :con_and
            yield(op, left.execute(&block), right.execute(&block))
          when :con_not
            yield(op, left.execute(&block))
          end || EMPTY_ARRAY
        end

        # Deal with chains of ANDs and ORs that are longer than two.
        # If both branches are of the specified type of operator,
        # then return both of them as an array (calling coalesce recursively).
        #
        # If they're not, then return an array consisting only of self.
        #
        # @return [Array]
        #
        # @api private
        def coalesce(operator)
          if op == operator
            [left.coalesce(operator), right.coalesce(operator)]
          else
            [self]
          end
        end

        # @return [Boolean]
        #
        # @api private
        def match(entry)
          case op
          when :eq
            if right == WILDCARD
              (l = entry[left]) && !l.empty?
            else
              (l = entry[left]) && (l = Array(l)) && l.index(right)
            end
          else
            raise FilterError, "Unknown filter type in match: #{op}"
          end
        end

      end
    end
  end
end
