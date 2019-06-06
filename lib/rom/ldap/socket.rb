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
      # option :timeout, type: Types::Strict::Integer, reader: :private, default: -> { 10 }

      option :read_timeout, type: Types::Strict::Integer, reader: :private, default: -> { 20 }

      option :write_timeout, type: Types::Strict::Integer, reader: :private, default: -> { 10 }

      option :retry_count, type: Types::Strict::Integer, reader: :private, default: -> { 3 }

      option :keep_alive, type: Types::Strict::Bool, reader: :private, default: -> { true }

      option :buffered, type: Types::Strict::Bool, reader: :private, default: -> { true }



      def call
        socket.do_not_reverse_lookup = true
        socket.sync = !!buffered
        socket.setsockopt(:SOCKET, :KEEPALIVE, keep_alive)
        socket.setsockopt(:TCP, :NODELAY, !!buffered)
        connect!
      end


      private


      #
      #
      # @return [::Socket]
      #
      def socket
        @socket ||= ::Socket.new((path ? :UNIX : :INET), :STREAM)
      end

      # @return [::Socket]
      #
      # @raise [ConnectionError]
      #
      def connect!
        socket.connect_nonblock(sockaddr)
        socket
      rescue Errno::EISCONN
        socket
      rescue IO::WaitWritable
        if writable?
          connect!
        else
          disconnect!
          raise ConnectionError, "Connection write timeout - #{host}:#{port}"
        end
      rescue IO::WaitReadable
        if readable?
          # TODO: retry_count
          retry
        else
          raise ConnectionError, "Connection read timeout - #{host}:#{port}"
        end
      rescue Errno::EADDRNOTAVAIL
        raise ConnectionError, "Host or port is invalid - #{host}:#{port}"
      rescue Errno::ENOENT
        raise ConnectionError, "Path to unix socket is invalid - #{path}"
      rescue Errno::EHOSTDOWN
        raise ConnectionError, "Server is down - #{host}:#{port}"
      rescue Errno::ECONNREFUSED
        raise ConnectionError, "Connection refused - #{host}:#{port}"
      rescue Errno::EAFNOSUPPORT
        raise ConnectionError, "Connection is not supported - #{host}:#{port}"
      rescue => e
        disconnect!
        raise ConnectionError, "Connection failed - #{host}:#{port}"
      end

      # @return [NilClass]
      #
      def disconnect!
        socket.close
        @socket = nil
      end


      #
      #
      # @return [String]
      #
      # @api private
      def sockaddr
        if addrinfo.unix?
          ::Socket.pack_sockaddr_un(addrinfo.unix_path)
        elsif addrinfo.ipv4?
          ::Socket.pack_sockaddr_in(addrinfo.ip_port, addrinfo.ip_address)
        end
      end

      # Does DNS lookup
      #
      # @return [Addrinfo]
      #
      # @api private
      def addrinfo
        return Addrinfo.unix(path) if path
        Addrinfo.tcp(host, port)
      rescue SocketError
        raise ConnectionError, "Host could not be resolved - #{host}:#{port}"
      end


      #
      # @api private
      def writable?
        IO.select(nil, [socket], nil, write_timeout)
      end


      #
      # @api private
      def readable?
        IO.select([socket], nil, nil, read_timeout)
      end


    end

  end
end
