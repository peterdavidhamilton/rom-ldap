require 'transproc'

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
        else
          nil
        end
      end

      def self.to_int(tuples)
        t(:map_array, t(:to_integer)).(tuples)
      end

      def self.to_sym(tuples)
        t(:map_array, t(:to_symbol)).(tuples)
      end

      def self.to_bool(tuples)
        # t(:map_array, t(:to_boolean)).(tuples)
        tuples.map { |t| Dry::Types['form.bool'][t] }
      end

      # def self.to_jpeg(tuples)
      #   tuples.map do |image|
      #     encoded = Base64.strict_encode64(image)
      #     "data:image/jpeg;base64,#{encoded}"
      #   end
      # end

      def self.to_time(tuples)
        tuples.map do |time|
          begin
            numeric_time = Integer(time)
            ten_k        = 10_000_000.freeze
            since_1601   = 11_644_473_600.freeze
            time         = (numeric_time / ten_k) - since_1601

            ::Time.at(time)
          rescue ArgumentError
            ::Time.parse(time).utc
          rescue ArgumentError
            nil
          end
        end
      end

      # value.to_s.tr('-','_').to_sym
      def self.snake_case_symbol(value)
        fn = t(:to_string) >> t(:to_underscore) >> t(:to_symbol)
        fn.(value)
      end

      def self.to_underscore(value)
        value.tr('-','_')
      end

      def self.fix_entity(tuple)
        t(:map_keys, t(:snake_case_symbol)).(tuple)
      end

      # def self.search_results(dataset)
      #   t(:map_array, t(:fix_entity)).(dataset)
      # end


      # convert to a format that can be saved as a string
      def self.ldap_compatible(tuple)
        t(:map_values, t(:string_input)).(tuple)
      end


    end
  end
end

