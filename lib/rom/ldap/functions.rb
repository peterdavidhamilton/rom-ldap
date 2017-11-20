require 'transproc'
require 'dry/core/inflector'

require 'rom/ldap/functions/query_exporter'
require 'rom/ldap/functions/filter_exporter'
require 'rom/ldap/functions/expression_exporter'

module ROM
  module LDAP
    module Functions
      extend Transproc::Registry

      import Transproc::Coercions
      import Transproc::ArrayTransformations
      import Transproc::HashTransformations

      def self.find_attr(attr_name)
        list =  if contain?(:attribute_list)
                  t(:attribute_list).call
                else
                  EMPTY_ARRAY
                end

        list.select { |a| a[:name] == attr_name }.first || EMPTY_HASH
      end

      def self.string_input(attribute)
        case attribute
        when Numeric    then attribute.to_s
        when Enumerable then attribute.map(&:to_s)
        when Hash       then attribute.to_json
        when String     then attribute
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

      def self.to_method_name(value)
        fn = t(:to_string) >> t(:to_underscore) >> t(:to_symbol)
        fn.call(value)
      end

      def self.coerce_tuple_in(tuple)
        t(:map_values, t(:string_input)).call(tuple)
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

      private

      def self.query
        @composer ||= QueryExporter.new
      end

      def self.filter
        @decomposer ||= FilterExporter.new
      end

      def self.expression
        @parser ||= ExpressionExporter.new
      end
    end
  end
end
