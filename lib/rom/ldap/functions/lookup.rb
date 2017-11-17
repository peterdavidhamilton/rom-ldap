module ROM
  module LDAP
    module Lookup

      # @param val [Symbol,String]
      #
      # @example
      #   id_constructor(:con_and) => '&'
      #   id_constructor('&') => :con_and
      #
      # @return [String,Symbol]
      #
      # @api private
      def id_constructor(val)
        val.is_a?(Symbol) ? CONSTRUCTORS[val] : CONSTRUCTORS.invert[val]
      end

      # @param val [Symbol,String]
      #
      # @example
      #   id_operator(:op_gte) => '>='
      #
      # @return [String,Symbol]
      #
      # @api private
      def id_operator(val)
        val.is_a?(Symbol) ? OPERATORS[val] : OPERATORS.invert[val]
      end

      # @param sym [Symbol,String]
      #
      # @example
      #   id_value(true) => 'TRUE'
      #   id_value('TRUE') => true
      #   id_value('peter hamilton') => 'peter hamilton'
      #
      # @return [Symbol,String,Boolean]
      #
      # @api private
      def id_value(val)
        if val.is_a?(Symbol)
          VALUES.fetch(val, val)
        else
          VALUES.invert.fetch(val, val)
        end
      end


    end
  end
end
