require 'rom/struct'

module ROM
  module LDAP
    # A tolerant subclass of ROM::Struct.
    # Not every entry uses each available attribute that was inferred or defined.
    # Inherit from this as a convenience when wanting a struct.
    #
    # @api public
    class Struct < ROM::Struct

      transform_types { |type| type.meta(omittable: true) }

      # Filter unused attributes when converting to Hash
      #
      # @return [Hash]
      #
      def to_h
        super.reject { |_k, v| v.nil? }
      end

    end
  end
end
