require 'rom/struct'

module ROM
  module LDAP
    class Struct < ROM::Struct
      transform_types { |type| type.meta(omittable: true) }

      # Remove unused attributes when converting to Hash
      #
      # @return [Hash]
      #
      def to_h
        super.delete_if { |_k, v| v.nil? }
      end

      private

      # Convenience method to alias attributes to instance methods.
      #
      def shortcut(*attributes)
        attributes.map { |m| return public_send(m) if respond_to?(m) }
      end
    end
  end
end
