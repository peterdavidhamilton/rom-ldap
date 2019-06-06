require 'openssl'
require 'ber'
require 'rom/initializer'

module ROM
  module LDAP
    #
    # Wraps a socket with SSL
    #
    class SecureSocket
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




      using ::BER

      extend Initializer

      param :socket

      option :cert, type: Types::Strict::String, reader: false
      option :key, type: Types::Strict::String, reader: false
      option :ca, type: Types::Strict::String, reader: false


      def call
        binding.pry
        context = OpenSSL::SSL::SSLContext.new

        context.set_params(
          cert: cert,
          key: key,
          ca_file: @ca,
          verify_mode: 0
          # verify_mode: OpenSSL::SSL::VERIFY_NONE
          )

        sock = OpenSSL::SSL::SSLSocket.new(socket, context)
        sock.extend(GetbyteForSSLSocket) unless @socket.respond_to?(:getbyte)
        sock.extend(FixSSLSocketSyncClose)
        sock

      rescue OpenSSL::X509::CertificateError
        binding.pry
      end

      private

      def cert
        OpenSSL::X509::Certificate.new(cert_file)
      end

      def key
        OpenSSL::PKey::RSA.new(key_file)
      end

      def cert_file
        load_file(@cert)
      end

      def key_file
        load_file(@key)
      end


      def load_file(file)
        File.open(file)
        rescue Errno::ENOENT
          raise ConfigError, "#{file} was not found"
      end

    end

  end
end
