require 'active_support/notifications'

module ROM
  module LDAP
    module ActiveSupportInstrumentation
      def call(filter)
        ActiveSupport::Notifications.instrument(
          'ldap.rom',
          ldap: 'foobar',
          name: instrumentation_name,
          binds: filter
        ) { super }
      end

      private

      def instrumentation_name
        "ROM[#{directory.type}]"
      end
    end

    Dataset.send(:prepend, ActiveSupportInstrumentation)
  end
end

