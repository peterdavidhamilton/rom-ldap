# frozen_string_literal: true

require 'socket'
require 'rom/initializer'

module GetbyteForSSLSocket
  def getbyte
    byte = getc
    return nil if byte.nil?

    byte.ord
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
    # Builds either TCP or UNIX.
    #
    # @api private
    class Socket

      extend Initializer

      # Unix socket absolute file path
      #
      # @!attribute [r] path
      #   @return [String]
      option :path, type: Types::Strict::String, reader: :private, optional: true

      # Domain name or IP for TCP connection
      #
      # @!attribute [r] host
      #   @return [String]
      option :host, type: Types::Strict::String, reader: :private, optional: true

      # TCP port
      #
      # @!attribute [r] host
      #   @return [Integer]
      option :port, type: Types::Strict::Integer, reader: :private, optional: true

      # OpenSSL
      # OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
      option :ssl, type: Types::Strict::Hash, reader: :private, optional: true

      # Config
      # option :timeout, type: Types::Strict::Integer, reader: :private, default: -> { 10 }

      option :read_timeout, type: Types::Strict::Integer, reader: :private, default: -> { 20 }

      # Timeout limit in seconds when writing to the socket
      #
      # @!attribute [r] write_timeout
      #   @return [Integer] default: 10
      option :write_timeout, type: Types::Strict::Integer, reader: :private, default: -> { 10 }

      # Retry limit when establishing connection
      #
      # @!attribute [r] retry_count
      #   @return [Integer] default: 3
      option :retry_count, type: Types::Strict::Integer, reader: :private, default: -> { 3 }

      #
      #
      # @!attribute [r] retry_count
      #   @return [Boolean] default: true
      option :keep_alive, type: Types::Strict::Bool, reader: :private, default: -> { true }

      #
      #
      # @!attribute [r] buffered
      #   @return [Boolean] default: true
      option :buffered, type: Types::Strict::Bool, reader: :private, default: -> { true }

      # @return [::Socket, ::OpenSSL::SSL::SSLSocket]
      #
      def call
        socket.do_not_reverse_lookup = true
        socket.sync = buffered
        socket.setsockopt(:SOCKET, :KEEPALIVE, keep_alive)
        socket.setsockopt(:TCP, :NODELAY, buffered) unless path

        connect!
      end

      private

      # @return [::Socket]
      #
      # @raise [ConnectionError]
      #
      def connect!
        @counter ||= 1

        if ssl
          require 'openssl'

          ctx = OpenSSL::SSL::SSLContext.new
          ctx.set_params(ssl)
          @socket = OpenSSL::SSL::SSLSocket.new(socket, ctx)
          # socket.extend(GetbyteForSSLSocket) unless socket.respond_to?(:getbyte)
          # socket.extend(FixSSLSocketSyncClose)
          socket.connect_nonblock
        else
          socket.connect_nonblock(sockaddr)
        end

        socket
      rescue Errno::EISCONN
        socket
      rescue IO::WaitWritable
        # OpenSSL::SSL::SSLErrorWaitWritable
        if writable?
          connect!
        else
          disconnect!
          raise ConnectionError, "Connection write timeout - #{host}:#{port}"
        end
      rescue IO::WaitReadable
        if readable?
          @counter += 1
          retry unless @counter > retry_count
        else
          raise ConnectionError, "Connection read timeout - #{host}:#{port}"
        end
      rescue Errno::EADDRNOTAVAIL
        raise ConnectionError, "Host or port is invalid - #{host}:#{port}"
      rescue SocketError
        raise ConnectionError, "Host could not be resolved - #{host}:#{port}"
      rescue Errno::ENOENT
        raise ConnectionError, "Path to unix socket is invalid - #{path}"
      rescue Errno::EHOSTDOWN
        raise ConnectionError, "Server is down - #{host}:#{port}"
      rescue Errno::ECONNREFUSED
        raise ConnectionError, "Connection refused - #{host}:#{port}"
      rescue Errno::EAFNOSUPPORT
        raise ConnectionError, "Connection is not supported - #{host}:#{port}"
      rescue
        disconnect!
        raise ConnectionError, "Connection failed - #{host}:#{port}"
      end

      #
      #
      # @return [::Socket]
      #
      def socket
        @socket ||= ::Socket.new((path ? :UNIX : :INET), :STREAM)
      end

      # @return [NilClass]
      #
      def disconnect!
        socket.close
        @socket = nil
      end

      # IPV4 or UNIX socket address
      #
      # @return [String] ASCII-8BIT
      #
      # @api private
      def sockaddr
        if addrinfo.unix?
          ::Socket.pack_sockaddr_un(addrinfo.unix_path)

        elsif addrinfo.ipv4?
          ::Socket.pack_sockaddr_in(addrinfo.ip_port, addrinfo.ip_address)

        elsif addrinfo.ipv6_loopback?
          ::Socket.pack_sockaddr_in(addrinfo.ip_port, '127.0.0.1')
        end
      end

      # Performs DNS lookup
      #
      # @return [Addrinfo]
      #
      # @api private
      def addrinfo
        return Addrinfo.unix(path) if path

        Addrinfo.tcp(host, port)
      end

      # @return [TrueClass,FalseClass]
      #
      # @api private
      def writable?
        !IO.select(nil, [socket], nil, write_timeout).nil?
      end

      # @return [TrueClass,FalseClass]
      #
      # @api private
      def readable?
        !IO.select([socket], nil, nil, read_timeout).nil?
      end

    end
  end
end
