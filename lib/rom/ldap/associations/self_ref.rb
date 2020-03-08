# frozen_string_literal: true

module ROM
  module LDAP
    module Associations
      module SelfRef
        def self.included(klass)
          super
          klass.memoize :join_keys, :source_attr, :target_attr
        end

        # @return [Hash]
        #
        # @api public
        def join_keys
          { source_attr => target_attr }
        end

        # @return [ROM::LDAP::Attribute]
        #
        # @api public
        def source_attr
          source[source_key]
        end

        # @return [ROM::LDAP::Attribute]
        #
        # @api public
        def target_attr
          target[target_key]
        end
      end
    end
  end
end
