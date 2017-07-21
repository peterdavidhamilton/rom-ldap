require 'transproc'

module ROM
  module LDAP
    module Functions
      extend Transproc::Registry

      import Transproc::Coercions
      import Transproc::ArrayTransformations
      import Transproc::HashTransformations

      def self.string_attribute(attribute)
        case attribute
        when Numeric    then attribute.to_s
        when Enumerable then attribute.map(&:to_s)
        when Hash       then attribute.to_json
        when String     then attribute
        else
          # binding.pry
          nil
        end
      end

      def self.ldap_compatible(tuple)
        t(:map_values, t(:string_attribute)).(tuple)
      end

    end
  end
end

