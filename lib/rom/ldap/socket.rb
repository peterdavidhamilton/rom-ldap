require 'socket'
require 'rom/initializer'

module ROM
  module LDAP
    #
    # builds either TCP or UNIX
    #
    class Socket
      extend Initializer

      # Unix
      option :path, type: Types::Strict::String, reader: :private, optional: true

      # TCP
      option :host, type: Types::Strict::String, reader: :private, optional: true

      option :port, type: Types::Strict::Integer, reader: :private, optional: true


      # OpenSSL
      option :ssl, type: Types::Strict::Hash, reader: :private, optional: true


      # Config
      option :timeout, type: Types::Strict::Integer, reader: :private, default: -> { 10 }
      # option :read_timeout, type: Types::Strict::Integer, reader: :private, default: -> { 30 }
      # option :write_timeout, type: Types::Strict::Integer, reader: :private, default: -> { 30 }

      # option :retry_count, type: Types::Strict::Integer, reader: :private, default: -> { 3 }

      option :keep_alive, type: Types::Strict::Bool, reader: :private, default: -> { true }

      option :buffered, type: Types::Strict::Bool, reader: :private, default: -> { true }


      # @return [Socket]
      #
      def call
        # socket = ::Socket.new((path ? :UNIX : :INET), :STREAM, 0)

        if keep_alive
          # socket.setsockopt(:SOCKET, :KEEPALIVE, 1)
          socket.setsockopt(:SOCKET, :KEEPALIVE, true)
          socket.do_not_reverse_lookup = false
        end

        unless buffered
          socket.sync = true
          # socket.setsockopt(:TCP, :NODELAY, 1)
          socket.setsockopt(:TCP, :NODELAY, true)
        end

        begin
          socket.connect_nonblock(sockaddr) # , exception: false)

        rescue Errno::EADDRNOTAVAIL
          raise ConnectionError, "Host or port is invalid - #{host}:#{port}"

        rescue Errno::EHOSTDOWN
          raise ConnectionError, "Server is down - #{host}:#{port}"

        rescue Errno::ECONNREFUSED
          raise ConnectionError, "Connection refused - #{host}:#{port}"

        rescue Errno::EAFNOSUPPORT
          raise ConnectionError, "Connection is not supported - #{host}:#{port}"

        rescue IO::WaitWritable
          # IO.select will block until the socket is writable or the timeout
          # is exceeded - whichever comes first.
          if writable?
            begin
              # Verify there is now a good connection
              socket.connect_nonblock(sockaddr)
            rescue Errno::EISCONN
              #=> This means connection to remote host has established successfully.
              socket
            rescue => error
              # An unexpected exception was raised - the connection is no good.
              socket.close
              raise ConnectionError, "Connection failed - #{host}:#{port}"
            end
          else
            # IO.select returns nil when the socket is not ready before timeout
            # seconds have elapsed
            socket.close
            raise ConnectionError, "Connection write timeout - #{host}:#{port}"
          end

        rescue IO::WaitReadable
          raise ConnectionError, "Connection read timeout - #{host}:#{port}" unless readable?
          retry
        end
      end


      private

      def socket
        return @socket if @socket

        socket = ::Socket.new((path ? :UNIX : :INET), :STREAM, 0)

        # if ssl

        #   tls_options = {
        #     cert:         OpenSSL::X509::Certificate.new(File.open(ssl[:cert])),
        #     key:          OpenSSL::PKey::RSA.new(File.open(ssl[:key])),
        #     ca_file:      '/Users/pdh/.minikube/ca.pem',
        #     verify_mode:  OpenSSL::SSL::VERIFY_NONE
        #   }


        #   ctx = OpenSSL::SSL::SSLContext.new
        #   ctx.set_params(tls_options) unless ssl.empty?

        #   ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ctx)


        #   ssl_socket.extend(GetbyteForSSLSocket) unless ssl_socket.respond_to?(:getbyte)
        #   ssl_socket.extend(FixSSLSocketSyncClose)

        #   @socket = ssl_socket
        # else
          @socket = socket
        # end
      rescue OpenSSL::X509::CertificateError => e
        binding.pry

      end

      #
      #
      # @return [String]
      #
      # @api private
      def sockaddr
        if host
          ::Socket.pack_sockaddr_in(addrinfo.ip_port, addrinfo.ip_address)
        else
          ::Socket.pack_sockaddr_un(addrinfo.path)
        end
      end

      #
      #
      # @return [Addrinfo]
      #
      # @api private
      def addrinfo
        if host
          Addrinfo.tcp(host, port)
        else
          Addrinfo.unix(path)
        end
      end


      #
      # @api private
      def writable?
        IO.select(nil, [socket], nil, timeout)
      end


      #
      # @api private
      def readable?
        IO.select([socket], nil, nil, timeout)
      end


    end

  end
end
