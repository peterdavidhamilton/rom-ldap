require 'rom/associations/many_to_many'

module ROM
  module LDAP
    module Associations
      class ManyToMany < ROM::Associations::ManyToMany
        # @api public
        def call(target: self.target)
          binding.pry
          left = join_assoc.call(target: target)

          schema =
            if left.schema.key?(foreign_key)
              if target != self.target
                target.schema.merge(join_schema)
              else
                left.schema.project(*columns)
              end
            else
              target_schema
            end.qualified

          relation = left.join(source.name.dataset, join_keys)

          if view
            apply_view(schema, relation)
          else
            schema.call(relation)
          end
        end

        # @api public
        def join(type, source = self.source, target = self.target)
          binding.pry
          through_assoc = source.associations[through]
          joined = through_assoc.join(type, source)
          joined.__send__(type, target.name.dataset, join_keys).qualified
        end

        # @api public
        def join_keys
          { source_attr => target_attr }
        end

        # @api public
        def source_attr
          source[source_key].qualified
        end

        # @api public
        def target_attr
          join_relation[target_key].qualified
        end

        # @api private
        def persist(children, parents)
          join_tuples = associate(children, parents)
          join_relation.multi_insert(join_tuples)
        end

        private

        # @api private
        def target_schema
          target.schema.merge(join_schema)
        end

        # @api private
        def join_schema
          join_relation.schema.project(foreign_key)
        end

        # @api private
        def columns
          target_schema.map(&:name)
        end

        memoize :join_keys, :target_schema, :join_schema, :columns
      end
    end
  end
end
