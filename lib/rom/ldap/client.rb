require 'rom/initializer'

require 'rom/ldap/pdu'
require 'rom/ldap/socket'
require 'rom/ldap/message_queue'

require 'rom/ldap/client/operations'

module GetbyteForSSLSocket
  def getbyte
    getc.ord
  end
end

module FixSSLSocketSyncClose
  def close
    super
    io.close
  end
end




module ROM
  module LDAP
    #
    # Uses socket to read and write
    #
    class Client
      using ::BER

      extend Initializer

      # host:port / path
      param :envs, reader: :private, type: Types::Strict::Hash

      # username / password
      param :auth, reader: :private, type: Types::Strict::Hash, optional: true

      # cert / key ...
      # param :ssl, reader: :private, type: Types::Strict::Hash, optional: true

      option :queue, default: -> { MessageQueue }

      include Operations

      attr_reader :socket

      def connect
        unless alive?
          @socket = Socket.new(envs).call

          if auth
            raise ConfigError, "Authentication failed for #{auth[:username]}" unless bind(auth).success?
          end

          # if ssl

          #   tls_options = {
          #     cert:    OpenSSL::X509::Certificate.new(File.open(ssl[:cert])),
          #     key:     OpenSSL::PKey::RSA.new(File.open(ssl[:key])),
          #     # cert:    OpenSSL::X509::Certificate.new(File.open('server.pem')),
          #     # key:     OpenSSL::PKey::RSA.new(File.open('server-key.pem')),
          #     ca_file: File.open('ca.pem')
          #     # verify_mode: OpenSSL::SSL::VERIFY_NONE
          #   }

          #   rescue OpenSSL::X509::CertificateError

          #   ctx = OpenSSL::SSL::SSLContext.new
          #   ctx.set_params(tls_options) unless ssl.empty?
          #   @socket = OpenSSL::SSL::SSLSocket.new(@socket, ctx)

          #   @socket.extend(GetbyteForSSLSocket) unless @socket.respond_to?(:getbyte)
          #   @socket.extend(FixSSLSocketSyncClose)
          # end
        end

        yield(@socket)
      end



      def closed?
        socket.nil? || (socket.is_a?(::Socket) && socket.closed?)
      end


      def close
        return if socket.nil?
        socket.close
        @socket = nil
      end


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
      #
      # @api private
      def pdu_lookup(symbol)
        ::BER.fetch(:response, symbol)
      end



      # Read from socket and wrap in PDU class.
      #
      # @return [PDU]
      #
      # @api private
      def read
        connect do |socket|
          return unless ber_object = socket.read_ber

          PDU.new(*ber_object)
        end
      rescue Errno::ECONNRESET => e
        close
        # TODO: use a counter here to prevent too many attempts
        retry
      end



      # Write to socket.
      #
      #
      #
      # @api private
      def write(request, controls = nil, message_id)
        connect do |socket|
          packet = [message_id.to_ber, request, controls].compact.to_ber_sequence
          socket.write(packet)
          socket.flush
        end
      rescue Errno::EPIPE, IOError => e
        # TODO: use a counter here to prevent too many attempts
        close
        retry
      end




      # @api private
      def from_queue(message_id)
        if pdu = queue[message_id].shift
          return pdu
        end

        while pdu = read
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




      # @return [PDU]
      #
      # @raise [ResponseMissingOrInvalidError]
      #
      #
      # @api private
      def submit(type, request, controls = nil)
        message_id = next_msgid

        write(request, controls, message_id)

        pdu = from_queue(message_id)

        if pdu&.app_tag == pdu_lookup(type)
          # puts pdu.advice if ENV['DEBUG'] && pdu.advice && !pdu.advice.empty?
          pdu
        else
          raise(ResponseMissingOrInvalidError, "Invalid #{type}")
        end
      end

    end
  end
end
