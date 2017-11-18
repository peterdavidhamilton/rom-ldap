require 'ber'

using ::BER

require 'net/tcp_client'
require 'rom/ldap/directory/pdu'
require 'rom/ldap/connection/authenticate'
require 'rom/ldap/connection/create'
require 'rom/ldap/connection/read'
require 'rom/ldap/connection/update'
require 'rom/ldap/connection/delete'

module ROM
  module LDAP
    class Connection < Net::TCPClient
      include Authenticate
      include Create
      include Read
      include Update
      include Delete

      def use_logger(logger)
        @logger = logger
      end

      private

      attr_reader :logger

      def pdu_lookup(symbol)
        ::BER.reverse_lookup(:pdu, symbol)
      end

      # TODO: NetTCP timeout in here
      # socket_read(length, buffer, timeout)

      # @api private
      def ldap_read(syntax = ::BER::ASN_SYNTAX)
        return unless ber_object = socket.read_ber(syntax)
        # return unless ber_object = socket_read(syntax, nil, read_timeout)
        # return unless ber_object = read(syntax)
        Directory::PDU.new(ber_object)
      end

      # @api private
      def ldap_write(request, controls = nil, message_id = next_msgid)
        packet = [message_id.to_ber, request, controls].compact.to_ber_sequence
        socket_write(packet, write_timeout)
      end

      # @api private
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

      # @return [Hash]
      #
      # @api private
      def message_queue
        @message_queue ||= Hash.new { |hash, key| hash[key] = [] }
      end

      # @return [Integer]
      #
      # @api private
      def next_msgid
        @msgid ||= 0
        @msgid += 1
      end

      # @return [Exception, Nil]
      #
      # @api private
      def validate_response(pdu, error_klass, pdu_response)
        raise(*error_klass) if !pdu || pdu.app_tag != pdu_response
      end
    end
  end
end
