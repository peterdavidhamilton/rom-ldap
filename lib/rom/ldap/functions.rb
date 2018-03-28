require 'transproc'
require 'rom/support/inflector'
require 'rom/ldap/functions/exporters'

module ROM
  module LDAP
    module Functions
      extend Transproc::Registry

      import Transproc::Coercions
      import Transproc::ArrayTransformations
      import Transproc::HashTransformations

      extend Exporters

      # Build tuple from arguments.
      # Translates keys into original schema names and stringify values.
      #
      # @param tuple [Hash] input arguments for directory #add and #modify
      #
      # @return [Hash]
      #   NB: Directory#add will receive a hash with key :dn
      #
      # @example
      #
      #   Functions[:tuplify].(
      #     {
      #       dn: 'uid=zippy,ou=users,dc=example,dc=com',
      #       apple_imhandle: '@zippy',
      #       gid_number: 1,
      #       given_name: 'Franz'
      #     }, {
      #       apple_imhandle: 'apple-imhandle',
      #       gid_number: 'gidNumber',
      #       given_name: 'givenName'
      #     }
      #   )
      #
      #     =>  {
      #       dn: 'uid=zippy,ou=users,dc=example,dc=com',
      #       'apple-imhandle' => '@zippy',
      #       'gidNumber' => '1',
      #       'givenName' => 'Franz',
      #     }
      #
      # @api public
      def self.tuplify(tuple, matrix)
        fn = t(:rename_keys, matrix) >>
             t(:map_values, t(:identify_value)) >>
             t(:map_values, t(:stringify))
        fn.call(tuple)
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
      # @api public
      def self.identify_value(val)
        case val
        when Symbol, TrueClass, FalseClass
          VALUES.fetch(val, val)
        else
          VALUES.invert.fetch(val, val)
        end
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

      # NB: Transproc::Coercions::TRUE_VALUES is missing 'TRUE'
      # Overwrite #to_boolean for LDAP context.
      #
      def self.to_boolean(tuple)
        Dry::Types['form.bool'][tuple]
      end

      def self.to_bool(tuples)
        t(:map_array, t(:to_boolean)).call(tuples)
      end

      def self.to_time(tuples)
        tuples.map do |time|
          begin
            ten_k      = 10_000_000
            since_1601 = 11_644_473_600
            time       = (Integer(time) / ten_k) - since_1601

            ::Time.at(time)
          rescue ArgumentError
            ::Time.parse(time).utc
          rescue ArgumentError
            nil
          end
        end
      end

      def self.to_underscore(value)
        Inflector.underscore(value.delete('= '))
      end

      # Function applied to Directory::Entry to format incoming attribute names.
      #
      # @api public
      def self.to_method_name(value)
        fn = t(:to_string) >> t(:to_underscore) >> t(:to_symbol)
        fn.call(value)
      end

      # 'filter' to 'query'
      #
      # @see QueryExporter
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
      # @see FilterExporter
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
      # @see ExpressionExporter
      #
      # @param input [Array, String]
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
