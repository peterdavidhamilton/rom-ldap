require 'rom/associations/one_to_many'

require 'rom/ldap/associations/core'
require 'rom/ldap/associations/self_ref'

module ROM
  module LDAP
    module Associations
      class OneToMany < ROM::Associations::OneToMany

        include Associations::Core
        include Associations::SelfRef

        # @api public
        def call(target: self.target)
          schema = target.schema
          target_fks = target.list(foreign_key).uniq
          relation = source.where(source.primary_key => target_fks)

          if view
            apply_view(schema, relation)
          else
            schema.call(relation)
          end
        end

      end
    end
  end
end
