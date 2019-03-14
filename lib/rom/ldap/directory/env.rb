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

        param :config, reader: :private, type: Types::Strict::Hash, default: -> { EMPTY_HASH }


              # TODO: allow setting a starting scope, filter and attributes through the uri?

              # def scope
              #   uri.scope or config.fetch(:scope, SCOPE_SUB)
              # end

              # def extensions
              #   uri.extensions
              # end

              # def hierarchical?
              #   uri.hierarchical?
              # end

              # Set default
              #
              # def attributes
              #   config.fetch(:attributes, uri.attributes)
              # end

              # def filter
              #   config.fetch(:filter, uri.filter)
              # end


        # @return [URI::LDAP, URI::LDAPS]
        #
        def uri
          URI(URI.unescape(connection || default_connection))
        end


        def base
          uri.dn or ::ENV.fetch('LDAPBASE', EMPTY_STRING)
        end


        def auth
          return unless bind_dn
          { username: bind_dn, password: bind_pw }
        end

        def ssl
          return unless uri.scheme.eql?('ldaps')
          {
            cert: '/Users/pdh/.minikube/machines/server.pem',
            # key: 'docker/files/certs/server-key.pem'
            key: '/Users/pdh/.minikube/machines/server-key.pem'
          }
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


        # @return [String]
        #
        def path
          uri.path unless uri.host
        end

        # @return [String]
        #
        def host
          uri.host unless path
        end

        # @return [Integer]
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

        # @return [String]
        #
        def default_host
          ::ENV.fetch('LDAPHOST', '127.0.0.1')
        end

        # @return [Integer]
        #
        def default_port
          ::ENV.fetch('LDAPPORT', 389)
        end

        # @return [String]
        #
        def default_connection
          "ldap://#{default_host}:#{default_port}"
        end

      end

    end
  end
end
