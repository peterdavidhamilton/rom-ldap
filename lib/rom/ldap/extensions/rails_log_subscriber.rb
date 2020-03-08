require 'active_support/log_subscriber'

module ROM
  module LDAP
    class RailsLogSubscriber < ActiveSupport::LogSubscriber

      def ldap(event)
        return unless logger.debug?

        payload = event.payload

        name = format('%s (%.1fms)', payload[:name], event.duration)
        ldap = payload[:ldap].squeeze(' ')
        binds = payload[:binds].to_a.inspect if payload[:binds]

        if odd?
          name = color(name, :cyan, true)
          ldap = color(ldap, nil, true)
        else
          name = color(name, :magenta, true)
        end

        debug "  #{name}  #{ldap}  #{binds}"
      end

      attr_reader :odd_or_even
      private :odd_or_even
      def odd?
        @odd_or_even = !odd_or_even
      end

    end

    RailsLogSubscriber.attach_to(:rom)
  end
end
