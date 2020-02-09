module ROM
  module LDAP
    module Associations
      # Core LDAP association API
      #
      # @api private
      module Core
        # Used when relation association override is not true
        #
        # @see https://github.com/rom-rb/rom/blob/master/core/lib/rom/relation.rb#L319
        #
        # @api private
        def preload(target, loaded)
          source_key, target_key = join_keys.flatten(1)
          target_pks = loaded.pluck(source_key.key).flatten.uniq
          target.where(target_key.key => target_pks)
        end
      end
    end
  end
end
