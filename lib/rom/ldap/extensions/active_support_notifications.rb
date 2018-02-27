require 'active_support/notifications'

module ROM
  module LDAP
    module ActiveSupportInstrumentation
      def call(filter)
        binding.pry

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
  end
end

ROM::LDAP::Dataset.send(:prepend, ROM::LDAP::ActiveSupportInstrumentation)
