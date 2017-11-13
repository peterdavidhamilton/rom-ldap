require 'dry-types'
require 'dry-initializer'
require 'rom/ldap/filter/expression/encoder'

# TODO: this logic should be in the deecomposer that turns ast into expression.
#
module ROM
  module LDAP
    module Filter
      # @api private
      class Expression

        extend Dry::Initializer

        param :op,    reader: :private, type: Dry::Types['strict.symbol']
        param :left,  reader: :private
        param :right, reader: :private, optional: true

        #
        # Constructors
        #
        def &(other)
          self.class.new(:and, self, other)
        end

        def |(other)
          self.class.new(:or, self, other)
        end

        def ~@
          self.class.new(:not, self, nil)
        end

        def to_raw_rfc2254
          case op
          when :ne  then        "!(#{left}=#{right})"
          when :eq, :bineq then "#{left}=#{right}"
          when :ex  then        "#{left}:=#{right}"
          when :ge  then        "#{left}>=#{right}"
          when :gt  then        "#{left}>#{right}"
          when :le  then        "#{left}<=#{right}"
          when :lt  then        "#{left}<#{right}"
          when :and then        "&(#{left.to_raw_rfc2254})(#{right.to_raw_rfc2254})"
          when :or  then        "|(#{left.to_raw_rfc2254})(#{right.to_raw_rfc2254})"
          when :not then        "!(#{left.to_raw_rfc2254})"
          end
        end

        def to_rfc2254
          "(#{to_raw_rfc2254})"
        end

        alias to_s to_rfc2254

        def to_ber
          Encoder.new(op, left, right).call
        end

        # @see [Filter::Expression::Decoder]
        #
        def execute(&block)
          binding.pry

          case op
          when :eq
            if right == WILDCARD
              yield :present, left
            elsif right.index WILDCARD
              yield(:substrings, left, right)
            else
              yield(:equalityMatch, left, right)
            end
          when :ge
            yield(:greaterOrEqual, left, right)
          when :le
            yield(:lessOrEqual, left, right)
          when :or, :and
            yield(op, left.execute(&block), right.execute(&block))
          when :not
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
