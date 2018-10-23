require 'transproc'
require 'base64'
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

      def self.to_hexidecimal(value)
        value.each_byte.map { |b| b.to_s(16) }.join.force_encoding(Encoding::UTF_8)
      end

      def self.to_hex(values)
        t(:map_array, t(:to_hexidecimal)).call(values)
      end

      # def self.to_decimal(value)
      #   value.each_byte.map { |b| b.to_s(10) }.join.force_encoding(Encoding::UTF_8)
      # end

      def self.to_binary(values)
        t(:map_array, t(:to_base64)).call(values)
      end

      # @see https://en.wikipedia.org/wiki/List_of_file_signatures
      # @see https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types/Complete_list_of_MIME_types
      # @see https://github.com/sdsykes/fastimage/blob/master/lib/fastimage.rb
      def self.to_base64(value)
        mime =
          case value[0, 2]
          when 0xff.chr + 0xd8.chr
            'image/jpeg'
          when 0x89.chr + 'P'
            'image/png'
          when 'BM'
            'image/bitmap'
          when 'II', 'MM'
            'image/tiff'
          when 0xff.chr + 0xfb.chr, 'ID'
            'audio/mpeg'
          when 'WA'
            'audio/x-wav'
          else
            'application/octet-stream'
          end

        ::Base64.strict_encode64(value).prepend("data:#{mime};base64,")
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

      # TODO: split and use map_array
      def self.to_time(tuples)
        tuples.map do |time|
          ten_k      = 10_000_000
          since_1601 = 11_644_473_600
          time       = (Integer(time) / ten_k) - since_1601

          ::Time.at(time)
      rescue ArgumentError
        ::Time.parse(time).utc
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
