# frozen_string_literal: true

module ROM
  module LDAP
    # @api private
    class Expression

      extend Initializer

      option :op, type: Types::Abstract

      option :field, optional: true, type: Types::Field

      option :value, optional: true, type: Types::Value

      option :exps,  optional: true, type: Types::Array.of(Types.Instance(Expression))

      #
      #
      # @return [String]
      #
      # @api public
      def to_ber
        require 'rom/ldap/expression_encoder'
        ExpressionEncoder.new(options).call
      end

      # Unbracketed filter string
      #
      # @return [String]
      #
      def to_raw_filter
        case op
        when :op_eql, :op_bineq then "#{field}=#{value}"
        when :op_ext  then "#{field}:=#{value}"
        when :op_gte  then "#{field}>=#{value}"
        when :op_lte  then "#{field}<=#{value}"
        when :op_prx  then "#{field}~=#{value}"
        when :con_and then "&#{exps.map(&:to_filter).join}"
        when :con_or  then "|#{exps.map(&:to_filter).join}"
        when :con_not then "!#{exps[0].to_filter}"
        end
      end

      # Bracketed filter string
      #
      # @return [String]
      #
      def to_filter
        "(#{to_raw_filter})"
      end
      alias to_s to_filter

      # AST with original atrributes and values
      #
      # @return [Array]
      #
      def to_ast
        case op
        when :con_and then [op, exps.map(&:to_ast)]
        when :con_or  then [op, exps.map(&:to_ast)]
        when :con_not then [op, exps[0].to_ast]
        else
          [op, field, value]
        end
      end
      alias to_a to_ast

      # @return [String]
      #
      def inspect
        %(#<#{self.class} #{to_raw_filter} />)
      end

    end
  end
end
