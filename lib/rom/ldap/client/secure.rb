using ::BER

# OpenSSL::SSL::SSLSocket extend with modules
#
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

# https://github.com/openmicroscopy/apacheds-docker/blob/master/instance/config.ldif



# dn: ads-serverId=kerberosServer,ou=servers,ads-directoryServiceId=default,ou=config
# objectclass: ads-server
# objectclass: ads-kdcServer
# objectclass: ads-dsBasedServer
# objectclass: ads-base
# objectclass: top
# ads-serverid: kerberosServer
# ads-enabled: FALSE
# ads-krbAllowableClockSkew: 300000
# ads-krbBodyChecksumVerified: TRUE
# ads-krbEmptyAddressesAllowed: TRUE
# ads-krbEncryptionTypes: aes128-cts-hmac-sha1-96
# ads-krbEncryptionTypes: des3-cbc-sha1-kd
# ads-krbEncryptionTypes: des-cbc-md5
# ads-krbForwardableAllowed: TRUE
# ads-krbmaximumrenewablelifetime: 604800000
# ads-krbMaximumTicketLifetime: 86400000
# ads-krbPaEncTimestampRequired: TRUE
# ads-krbPostdatedAllowed: TRUE
# ads-krbPrimaryRealm: EXAMPLE.COM
# ads-krbProxiableAllowed: TRUE
# ads-krbRenewableAllowed: TRUE
# ads-searchBaseDN: ou=users,dc=openmicroscopy,dc=org


# dn: ads-serverId=ldapServer,ou=servers,ads-directoryServiceId=default,ou=config
# objectclass: ads-server
# objectclass: ads-ldapServer
# objectclass: ads-dsBasedServer
# objectclass: ads-base
# objectclass: top
# ads-serverId: ldapServer
# ads-confidentialityRequired: FALSE
# ads-maxSizeLimit: 1000
# ads-maxTimeLimit: 15000
# ads-maxpdusize: 2000000
# ads-saslHost: ldap.example.com
# ads-saslPrincipal: ldap/ldap.example.com@EXAMPLE.COM
# ads-saslRealms: example.com
# ads-saslRealms: apache.org
# ads-searchBaseDN: ou=users,ou=system
# ads-replEnabled: true
# ads-replPingerSleep: 5
# ads-enabled: TRUE


module ROM
  module LDAP
    class Client
      # LDAP::Connection login methods
      #
      module Secure

        private

        # patch ssl setting
        #
        def ssl_connect(socket, address, timeout)
          binding.pry
          ssl_socket = super
          ssl_socket.extend(GetbyteForSSLSocket) unless ssl_socket.respond_to?(:getbyte)
          ssl_socket.extend(FixSSLSocketSyncClose)
          ssl_socket
        end





        # #
        # #  :simple_tls or :start_tls
        # #
        # def setup_encryption(method:, tls_options: EMPTY_OPTS, timeout: nil)

        #   request_type = pdu_lookup(:extended_request)
        #   message_id  = next_msgid

        #   case method
        #   when :simple_tls
        #     @conn = wrap_with_ssl(@conn, tls_options, timeout)

        #   when :start_tls
        #     request = [
        #       START_TLS.to_ber_contextspecific(0)
        #     ].to_ber_appsequence(request_type)

        #     ldap_write(request, nil, message_id)

        #     pdu = from_queue(message_id)

        #     raise(SecureBindError, 'no start_tls result') if !pdu&.extended_response?

        #     raise(SecureBindError, "start_tls failed: #{pdu.result_code}") unless pdu.result_code.zero?

        #     @conn = wrap_with_ssl(@conn, tls_options, timeout)

        #   else
        #     raise ArgumentError, "unsupported encryption method '#{method}'"
        #   end
        # end




        # def wrap_with_ssl(io, tls_options, timeout)

        #   begin
        #     require 'openssl'
        #   rescue LoadError
        #     raise ConfigError, 'OpenSSL is unavailable'
        #   end

        #   ctx = OpenSSL::SSL::SSLContext.new
        #   ctx.set_params(tls_options) unless tls_options.empty?

        #   conn = OpenSSL::SSL::SSLSocket.new(io, ctx)

        #   begin
        #     if timeout
        #       conn.connect_nonblock
        #     else
        #       conn.connect
        #     end
        #   rescue IO::WaitReadable
        #     raise Errno::ETIMEDOUT, 'OpenSSL connection read timeout' unless
        #       IO.select([conn], nil, nil, timeout)
        #     retry

        #   rescue IO::WaitWritable
        #     raise Errno::ETIMEDOUT, 'OpenSSL connection write timeout' unless
        #       IO.select(nil, [conn], nil, timeout)
        #     retry

        #   end

        #   conn.extend(GetbyteForSSLSocket) unless conn.respond_to?(:getbyte)
        #   conn.extend(FixSSLSocketSyncClose)
        #   conn
        # end


      end
    end
  end
end
