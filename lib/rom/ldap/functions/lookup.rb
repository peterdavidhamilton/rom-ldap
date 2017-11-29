module ROM
  module LDAP
    module Lookup
      # Map formatted name back to ldap name
      #
      # @param attribute [String, Symbol] canonical attribute name used in application.
      #
      # @return [String] original attribute name used on server.
      #
      # @example
      #   id_attribute(:uid_number) => 'uidNumber'
      #
      # # @api private
      def id_attribute(attr_name)
        dir_attrs = Directory.attributes || EMPTY_ARRAY
        attribute = dir_attrs.detect { |a| a[:name].eql?(attr_name) }
        attribute ? attribute[:original] : attr_name
      end

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

      # # @param sym [Symbol,String]
      # #
      # # @example
      # #   id_value(true) => 'TRUE'
      # #   id_value('TRUE') => true
      # #   id_value('peter hamilton') => 'peter hamilton'
      # #
      # # @return [Symbol,String,Boolean]
      # #
      # # @api private
      # def id_value(val)
      #   Functions[:identify_value].call(val)
      # end
    end
  end
end
