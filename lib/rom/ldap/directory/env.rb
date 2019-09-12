require 'rom/initializer'

module ROM
  module LDAP
    class Directory
      #
      #
      # ldapurl    = scheme "://" [hostport] ["/" [dn ["?" [attributes] ["?" [scope]  ["?" [filter] ["?" extensions]]]]]]
      # scheme     = "ldap"
      # attributes = attrdesc *("," attrdesc)
      # scope      = "base" / "one" / "sub"
      # dn         = distinguishedName from Section 3 of [1]
      # hostport   = hostport from Section 5 of RFC 1738 [5]
      # attrdesc   = AttributeDescription from Section 4.1.5 of [2]
      # filter     = filter from Section 4 of [4]
      # extensions = extension *("," extension)
      # extension  = ["!"] extype ["=" exvalue]
      # extype     = token / xtoken
      # exvalue    = LDAPString from section 4.1.2 of [2]
      # token      = oid from section 4.1 of [3]
      # xtoken     = ("X-" / "x-") token
      #
      # @see https://ldapwiki.com/wiki/LDAP%20URL
      # @see https://docs.oracle.com/cd/E19957-01/816-6402-10/url.htm
      #
      # parse environment variables
      #
      class ENV

        extend Initializer

        param :connection, reader: :private, type: Types::URI, default: -> { ::ENV['LDAPURI'] }

        param :config, reader: :private, type: Types::Strict::Hash, default: -> { EMPTY_OPTS }


        # @return [URI::LDAP, URI::LDAPS]
        #
        def uri
          URI(URI.decode_www_form_component(connection || default_connection))
        end

        # @return [String]
        #
        def base
          connection ? uri.dn : ::ENV.fetch('LDAPBASE', EMPTY_STRING)
        end

        # @return [Hash, NilClass]
        #
        def auth
          { username: bind_dn, password: bind_pw } if bind_dn
        end

        # @return [Hash, NilClass]
        #
        def ssl
          config[:ssl] if uri.scheme.eql?('ldaps')
        end

        # @return [Hash]
        #
        def to_h
          { host: host, port: port, path: path, ssl: ssl, **config }
        end

        # @return [String]
        #
        def inspect
          "<#{self.class.name} uri=#{uri} />".freeze
        end


        private


        # @return [String, NilClass]
        #
        def path
          uri.path unless uri.host
        end

        # @return [String, NilClass]
        #
        def host
          uri.host unless path
        end

        # @return [Integer, NilClass]
        #
        def port
          uri.port unless path
        end

        # @return [String]
        #
        def bind_dn
          config.fetch(:username, ::ENV['LDAPBINDDN'])
        end

        # @return [String]
        #
        def bind_pw
          config.fetch(:password, ::ENV['LDAPBINDPW'])
        end

        # LDAPHOST or 127.0.0.1
        #
        # @return [String]
        #
        def default_host
          ::ENV.fetch('LDAPHOST', '127.0.0.1')
        end

        # LDAPPORT or 389
        #
        # @return [Integer]
        #
        def default_port
          ::ENV.fetch('LDAPPORT', 389)
        end

        #
        #
        # @return [String]
        #
        def default_connection
          "ldap://#{default_host}:#{default_port}"
        end

      end

    end
  end
end
