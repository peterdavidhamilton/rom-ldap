require 'net/tcp_client'
require 'rom/ldap/constants'

require 'dry/core/class_attributes'

require_relative 'default_socket'

require_relative 'writing'
require_relative 'modify'
require_relative 'searching'



# Load Core Extensions
require 'net/ber'
require 'net/ldap/pdu' # socket ldap read
require 'net/ldap/auth_adapter'
require 'psych'



module ROM
  module LDAP
    # class Connection < Net::TCPClient
    class Connection

      defines :connect_timeout
      defines :ldap_version
      defines :max_sasl_challenges

      connect_timeout 5
      ldap_version 3
      max_sasl_challenges 10


      # config in YAML
      compile_syntax = Psych.load_file('./lib/rom/ldap/syntax.yaml')
      ASN_SYNTAX     = Net::BER.compile_syntax(compile_syntax).freeze


      include Searching
      include Writing
      include Modify

      private

      def ldap_read(syntax = ASN_SYNTAX)
        return unless ber_object = socket.read_ber(syntax)

        Net::LDAP::PDU.new(ber_object)
      end

      def ldap_write(request, controls = nil, message_id = next_msgid)
        packet = [message_id.to_ber, request, controls].compact.to_ber_sequence
        socket.write(packet)
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

      def bind(method:)
        adapter_klass = Net::LDAP::AuthAdapter[method]
        adapter = adapter_klass.new(self)
        adapter.bind(method: method, username: '', dn: nil, password: '' )
      end

      def encode_sort_controls(sort_definitions)
        return sort_definitions unless sort_definitions

        sort_control_values = sort_definitions.map do |control|
          control = Array(control)

          control[0] = String(control[0]).to_ber,
          control[1] = String(control[1]).to_ber,
          control[2] = (control[2] == true).to_ber

          control.to_ber_sequence
        end

        sort_control = [
          SORT_REQUEST.to_ber,
          false.to_ber,
          sort_control_values.to_ber_sequence.to_s.to_ber
        ].to_ber_sequence
      end

    end
  end
end
