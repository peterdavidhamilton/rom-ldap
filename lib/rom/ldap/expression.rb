require 'rom/ldap/expression_encoder'

module ROM
  module LDAP
    # @api private
    class Expression
      extend Initializer

      param :op, type: Types::Abstract

      param :left, type: Types::Field | Types.Instance(Expression)

      param :right, optional: true, type: Types::Value | Types.Instance(Expression)


      # Bracketed filter string
      #
      # @return [String]
      #
      def to_filter
        "(#{to_raw_filter})"
      end
      alias to_s to_filter

      # Unbracketed filter string
      #
      # @return [String]
      #
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

      # @return [String]
      #
      def inspect
        %(#<#{self.class} op=#{op} left=#{left} right=#{right} />)
      end

      # @return [String]
      #
      def to_ber
        ExpressionEncoder.new(*options.values).call
      end

      def with(sym, other = nil)
        self.class.new(sym, self, other)
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
