require 'rom/relation/wrap'

module ROM
  module LDAP
    # Specialized wrap relation for LDAP
    # @api public
    class Wrap < Relation::Wrap
      # Return a schema which includes attributes from wrapped relations
      #
      # @return [Schema]
      #
      # @api public
      def schema
        root.schema.merge(nodes.map(&:schema).reduce(:merge)).qualified
      end

      # Internal method used by abstract `ROM::Relation::Wrap`
      #
      # @return [Relation]
      #
      # @api private
      def relation
        relation = nodes.reduce(root) do |a, e|
          a.associations[e.name.key].join(:join, a, e)
        end
        schema.(relation)
      end
    end
  end
end
