using ::BER

require 'net/tcp_client'
require 'dry/core/class_attributes'
require 'rom/ldap/operations'

module ROM
  module LDAP
    class Connection < Net::TCPClient

      extend Dry::Core::ClassAttributes

      # defines :connect_timeout
      # defines :max_sasl_challenges
      # defines :result_size
      # connect_timeout     5
      # max_sasl_challenges 10
      # result_size         1_000

      defines :ldap_version
      defines :default_base
      defines :default_filter

      ldap_version    3
      default_base    EMPTY_STRING
      default_filter  '(objectClass=*)'.freeze

      attr_accessor :directory_options

      include Search
      include Create
      include Delete
      include Update
      include Authenticate

      private

      def use_logger=(logger)
        @logger = logger
      end

      def logger
        binding.pry
        @logger || directory_options[:logger]
      end

      def find_pdu(symbol)
        ::BER.reverse_lookup(:pdu, symbol)
      end

      # TODO: NetTCP timeout in here
      # socket_read(length, buffer, timeout)

      def ldap_read(syntax = ::BER::ASN_SYNTAX)
        return unless ber_object = socket.read_ber(syntax)
        # return unless ber_object = socket_read(syntax, nil, read_timeout)
        # return unless ber_object = read(syntax)

        ::BER::PDU.new(ber_object)
      end

      # time   = directory_options[:time] || self.class.connect_timeout

      def ldap_write(request, controls = nil, message_id = next_msgid)
        packet = [message_id.to_ber, request, controls].compact.to_ber_sequence
        socket_write(packet, write_timeout)
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
