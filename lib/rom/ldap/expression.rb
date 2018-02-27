require 'dry-types'
require 'dry-initializer'
require 'rom/ldap/expression/encoder'

module ROM
  module LDAP
    # @api private
    class Expression
      extend Dry::Initializer

      param :op, type: Dry::Types['strict.symbol']
      param :left
      param :right, optional: true


      def to_raw_rfc2254
        case op
        when :con_not then        "!(#{left}=#{right})"
        when :op_eql, :op_bineq then "#{left}=#{right}"
        when :op_ext  then        "#{left}:=#{right}"
        when :op_prx  then        "#{left}~=#{right}"
        when :op_gte  then        "#{left}>=#{right}"
        when :op_lte  then        "#{left}<=#{right}"
        when :con_and then        "&(#{left.to_raw_rfc2254})(#{right.to_raw_rfc2254})"
        when :con_or  then        "|(#{left.to_raw_rfc2254})(#{right.to_raw_rfc2254})"
        when :con_not then        "!(#{left.to_raw_rfc2254})"
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
        when :op_eql
          if right == WILDCARD
            yield(:present, left)
          elsif right.index WILDCARD
            yield(:substring, left, right)
          else
            yield(:equality_match, left, right)
          end
        when :con_or, :con_and
          yield(op, left.execute(&block), right.execute(&block))
        when :con_not
          yield(op, left.execute(&block))
        else
          yield(op, left, right)
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



      #
      # Constructors
      #
      def &(other)
        constructor(:con_and, other)
      end

      def |(other)
        constructor(:con_or, other)
      end

      def ~@
        constructor(:con_not)
      end

      private

      def constructor(sym, other = nil)
        self.class.new(sym, self, other)
      end

    end
  end
end
