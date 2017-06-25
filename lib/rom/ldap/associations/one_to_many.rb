require 'rom/associations/one_to_many'

module ROM
  module Ldap
    module Associations
      class OneToMany < ROM::Associations::OneToMany

        # @api public
        def call(target: self.target)
          binding.pry
          schema = target.schema.qualified
          relation = target.join(source_table, join_keys)

          if view
            apply_view(schema, relation)
          else
            schema.(relation)
          end
        end

        # @api public
        def join(type, source = self.source, target = self.target)
          binding.pry
          source.__send__(type, target.name.dataset, join_keys).qualified
        end
      end
    end
  end
end
