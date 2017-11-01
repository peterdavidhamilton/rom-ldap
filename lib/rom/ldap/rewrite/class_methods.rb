module ROM
  module LDAP
    class Connection
      module ClassMethods


        MODIFY_OPERATIONS = { add: 0, delete: 1, replace: 2 }.freeze


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

        def self.wrap_with_ssl(io, tls_options = {}, timeout=nil)
          raise Net::LDAP::NoOpenSSLError, "OpenSSL is unavailable" unless Net::LDAP::HasOpenSSL

          ctx = OpenSSL::SSL::SSLContext.new

          ctx.set_params(tls_options) unless tls_options.empty?

          conn = OpenSSL::SSL::SSLSocket.new(io, ctx)

          begin
            if timeout
              conn.connect_nonblock
            else
              conn.connect
            end
          rescue IO::WaitReadable
            raise Errno::ETIMEDOUT, "OpenSSL connection read timeout" unless
              IO.select([conn], nil, nil, timeout)
            retry
          rescue IO::WaitWritable
            raise Errno::ETIMEDOUT, "OpenSSL connection write timeout" unless
              IO.select(nil, [conn], nil, timeout)
            retry
          end

          conn.extend(GetbyteForSSLSocket) unless conn.respond_to?(:getbyte)
          conn.extend(FixSSLSocketSyncClose)

          conn
        end





        def self.modify_ops(operations)
          ops = []
          if operations
            operations.each do |op, attrib, values|
              op_ber = MODIFY_OPERATIONS[op.to_sym].to_ber_enumerated
              values = [values].flatten.map { |v| v.to_ber if v }.to_ber_set
              values = [attrib.to_s.to_ber, values].to_ber_sequence
              ops << [op_ber, values].to_ber
            end
          end
          ops
        end


      end
    end
  end
end
