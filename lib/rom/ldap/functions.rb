require 'transproc'
require 'dry/core/inflector'
require 'rom/ldap/functions/exporters'

module ROM
  module LDAP
    module Functions
      extend Transproc::Registry

      import Transproc::Coercions
      import Transproc::ArrayTransformations
      import Transproc::HashTransformations

      extend Exporters

      # @param attr_name [String, Symbol] Canonical name of the attribute
      #
      # @return [Hash] Attribute
      #
      # @api public
      def self.find_attr(attr_name)
        attrs = contain?(:attribute_list) ? t(:attribute_list).call : EMPTY_ARRAY
        attrs.select { |a| a[:name] == attr_name }.first || EMPTY_HASH
      end

      # Build tuple from arguments. Translates keys into original schema names.
      #
      # @param tuple [Hash] input arguments for directory #add and #modify
      #
      # @return [Hash] Stringified hash
      #   NB: Directory#add will receive a hash with key :dn
      #
      # @example
      #   {
      #      dn: 'uid=zippy,ou=users,dc=example,dc=com',
      #      'apple-imhandle' => '@zippy',
      #      'gidNumber' => '1',
      #      'givenName' => 'Franz',
      #   }
      #
      # @api public
      def self.tuplify(tuple, matrix)
        fn = t(:rename_keys, matrix) >> t(:map_values, t(:stringify))
        fn.call(tuple)
      end

      # Ensure tuple values are strings
      #
      # @param value [Mixed]
      #
      # @return [String, Array<String>]
      #
      # @api public
      def self.stringify(value)
        case value
        when Numeric    then value.to_s
        when Enumerable then value.map(&:to_s)
        when Hash       then value.to_json
        when String     then value
        end
      end

      def self.to_int(tuples)
        t(:map_array, t(:to_integer)).call(tuples)
      end

      def self.to_sym(tuples)
        t(:map_array, t(:to_symbol)).call(tuples)
      end

      def self.to_bool(tuples)
        tuples.map { |t| Dry::Types['form.bool'][t] }
      end

      def self.to_time(tuples)
        tuples.map do |time|
          begin
            ten_k        = 10_000_000
            since_1601   = 11_644_473_600
            time         = (Integer(time) / ten_k) - since_1601

            ::Time.at(time)
          rescue ArgumentError
            ::Time.parse(time).utc
          rescue ArgumentError
            nil
          end
        end
      end

      def self.to_underscore(value)
        Dry::Core::Inflector.underscore(value)
      end

      # Function applied to Directory::Entity to format incoming attribute names.
      #
      # @api public
      def self.to_method_name(value)
        fn = t(:to_string) >> t(:to_underscore) >> t(:to_symbol)
        fn.call(value)
      end

      # 'filter' to 'query'
      #
      # @param input [String]
      #
      # @return [Array]
      #
      # @api public
      def self.to_ast(input)
        query.call(input)
      end

      # 'query' to 'filter'
      #
      # @param input [Array]
      #
      # @return [String]
      #
      # @api public
      def self.to_ldap(input)
        filter.call(input)
      end

      # 'query' or 'filter' to 'expression'
      #
      # @param input [Array,String]
      # @param attributes [Array<Hash>]
      #
      # @return [Expression]
      #
      # @api public
      def self.to_exp(input)
        if input.is_a?(String)
          expression.call(input)
        else
          expression[to_ldap(input)]
        end
      end
    end
  end
end
