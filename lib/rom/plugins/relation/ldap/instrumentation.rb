# frozen_string_literal: true

require 'rom/plugins/relation/instrumentation'

module ROM
  module Plugins
    module Relation
      module LDAP
        # @api private
        module Instrumentation
          def self.included(klass)
            super

            klass.class_eval do
              include ROM::Plugins::Relation::Instrumentation

              # @overload [Hash]
              #
              # @api private
              def notification_payload(relation)
                super.merge(query: relation.to_filter)
              end
            end
          end
        end
      end
    end
  end
end

ROM.plugins do
  adapter :ldap do
    register :instrumentation, ROM::Plugins::Relation::LDAP::Instrumentation, type: :relation
  end
end
