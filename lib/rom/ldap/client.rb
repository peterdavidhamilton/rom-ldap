require 'ber'

require 'rom/initializer'
require 'rom/ldap/message_queue'
require 'rom/ldap/pdu'
require 'rom/ldap/socket'
require 'rom/ldap/client/operations'
require 'rom/ldap/client/authentication'

module ROM
  module LDAP
    #
    # Uses socket to read and write using BER encoding.
    #
    # @api private
    class Client

      using ::BER

      extend Initializer

      # @!attribute [r] host
      #   @return [String]
      option :host, reader: :private, type: Types::Strict::String

      option :port, reader: :private, type: Types::Strict::Integer
      option :path, reader: :private, type: Types::Strict::String
      option :auth, reader: :private, type: Types::Strict::Hash, optional: true
      option :ssl,  reader: :private, type: Types::Strict::Hash, optional: true
      option :queue, default: -> { MessageQueue }

      include Operations
      include Authentication

      attr_reader :socket

      # Create connection (encrypted) and authenticate.
      #
      # @yield [Socket]
      #
      # @raise [BindError, SecureBindError]
      def open
        unless alive?
          @socket = Socket.new(options).call

          # tls
          if ssl
            start_tls
            sasl_bind # (mechanism:, credentials:, challenge:)
          end

          bind(auth) unless auth.nil? # simple auth
        end

        yield(@socket)
      end

      # @return [TrueClass, FalseClass]
      #
      def closed?
        socket.nil? || (socket.is_a?(::Socket) && socket.closed?)
      end

      # @return [NilClass]
      #
      def close
        return if socket.nil?

        socket.close
        @socket = nil
      end

      # @return [TrueClass, FalseClass]
      #
      def alive?
        return false if closed?

        if IO.select([socket], nil, nil, 0)
          !socket.eof? rescue false
        else
          true
        end
      rescue IOError
        false
      end

      private

      # @see BER
      #
      # @param symbol [Symbol]
      #
      # @return [Integer]
      def pdu_lookup(symbol)
        ::BER.fetch(:response, symbol)
      end

      # Read from socket and wrap in PDU class.
      #
      # @return [PDU, NilClass]
      def read
        open do |socket|
          return unless (ber_object = socket.read_ber)

          PDU.new(*ber_object)
        end
      rescue Errno::ECONNRESET
        close
        retry
      end

      # Write to socket.
      #
      # @api private
      def write(request, message_id, controls = nil)
        open do |socket|
          packet = [message_id.to_ber, request, controls].compact.to_ber_sequence
          socket.write(packet)
          socket.flush
        end
      rescue Errno::EPIPE, IOError
        close
        retry
      end

      # @return [PDU]
      #
      # @api private
      def from_queue(message_id)
        if (pdu = queue[message_id].shift)
          return pdu
        end

        while (pdu = read)
          return pdu if pdu.message_id.eql?(message_id)

          queue[pdu.message_id].push(pdu)
          next
        end

        pdu
      end

      # Increment the message counter.
      #
      # @return [Integer]
      #
      # @api private
      def next_msgid
        @msgid ||= 0
        @msgid += 1
      end

      # Persist changes to the server and return response object.
      # Enable stdout debugging with DEBUG=y.
      #
      # @return [PDU]
      #
      # @raise [ResponseError]
      #
      # @api private
      def submit(type, request, controls = nil)
        message_id = next_msgid

        write(request, message_id, controls)

        pdu = from_queue(message_id)

        if pdu&.app_tag == pdu_lookup(type)
          puts pdu.advice if ENV['DEBUG'] && pdu.advice && !pdu.advice.empty?
          pdu
        else
          raise(ResponseError, "Invalid #{type}")
        end
      end

    end
  end
end
