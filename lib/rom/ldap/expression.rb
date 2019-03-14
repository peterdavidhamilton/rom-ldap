require 'rom/ldap/expression_encoder'

module ROM
  module LDAP
    # @api private
    class Expression
      extend Initializer

      ExpType = Types::String | Types.Instance(Expression)

      param :op, type: Types::Strict::Symbol

      param :left, type: ExpType

      param :right, optional: true, type: ExpType

      def to_filter
        "(#{to_raw_filter})"
      end

      alias to_s to_filter

      def to_raw_filter
        case op
        when :con_not then "!(#{left}=#{right})"
        when :op_eql  then "#{left}=#{right}"
        when :op_ext  then "#{left}:=#{right}"
        when :op_prx  then "#{left}~=#{right}"
        when :op_gte  then "#{left}>=#{right}"
        when :op_lte  then "#{left}<=#{right}"
        when :con_and then "&(#{left.to_raw_filter})(#{right.to_raw_filter})"
        when :con_or  then "|(#{left.to_raw_filter})(#{right.to_raw_filter})"
        when :con_not then "!(#{left.to_raw_filter})"
        end
      end

      def inspect
        %(#<#{self.class} op=#{op} left=#{left} right=#{right} />)
      end

      def to_ber
        ExpressionEncoder.new(op, left, right).call
      end

      def with(sym, other = nil)
        self.class.new(sym, self, other)
      end

      def [](args)
        # noop - allows Type.Instance(?)
      end

      # @return [Array]
      #
      # @api private
      def join_with(operator)
        if op == operator
          [left.join_with(operator), right.join_with(operator)]
        else
          [self]
        end
      end

    end
  end
end
