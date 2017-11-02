require 'net/tcp_client'
require 'dry/core/class_attributes'
require 'rom/ldap/operations'

# net-ldap - core_exts, ber, pdu, adapter
# require 'net/ber'
# require 'net/ldap/pdu'


module ROM
  module LDAP
    class Connection < Net::TCPClient

      extend Dry::Core::ClassAttributes

      defines :connect_timeout
      defines :ldap_version
      defines :max_sasl_challenges

      connect_timeout 5
      ldap_version 3
      max_sasl_challenges 10


      ASN_SYNTAX = Net::BER.compile_syntax(ROM::LDAP.config[:syntax]).freeze

      include Search
      include Create
      include Delete
      include Update
      include Authenticate


      private

      def ldap_read(syntax = ASN_SYNTAX)
        return unless ber_object = socket.read_ber(syntax)

        Net::LDAP::PDU.new(ber_object)
      end

      def ldap_write(request, controls = nil, message_id = next_msgid)
        packet = [message_id.to_ber, request, controls].compact.to_ber_sequence

        socket_write(packet, self.class.connect_timeout)
      end

      def queued_read(message_id)
        if pdu = message_queue[message_id].shift
          return pdu
        end

        while pdu = ldap_read
          return pdu if pdu.message_id == message_id
          message_queue[pdu.message_id].push pdu
          next
        end

        pdu
      end

      def message_queue
        @message_queue ||= Hash.new { |hash, key| hash[key] = [] }
      end

      def next_msgid
        @msgid ||= 0
        @msgid += 1
      end

      def catch_error(pdu, error_klass, pdu_response)
        raise(*error_klass) if (!pdu || pdu.app_tag != pdu_response)
      end

    end
  end
end
