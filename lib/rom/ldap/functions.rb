require 'transproc'
require 'dry/core/inflector'

module ROM
  module LDAP
    module Functions
      extend Transproc::Registry

      import Transproc::Coercions
      import Transproc::ArrayTransformations
      import Transproc::HashTransformations

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
            numeric_time = Integer(time)
            ten_k        = 10_000_000
            since_1601   = 11_644_473_600
            time         = (numeric_time / ten_k) - since_1601

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

      # fired by struct if its schema hash keys include a hyphen
      def self.fix_entity(tuple)
        t(:map_keys, t(:to_method_name)).call(tuple)
      end

      # should be to stringify keys before inserting to database
      def self.coerce_tuple(tuple)
        t(:map_values, t(:string_input)).call(tuple)
      end
    end
  end
end
