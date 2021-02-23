# frozen_string_literal: true

require 'rom/initializer'
require 'uri'

module ROM
  module LDAP
    class Directory

      # Parse uri and options received by the gateway configuration.
      #
      # @example
      #   scheme:// binddn : passwd @ host : port / base
      #   ldap://uid=admin,ou=system:secret@localhost:1389/ou=users,dc=rom,dc=ldap
      #
      # @see https://ldapwiki.com/wiki/LDAP%20URL
      # @see https://docs.oracle.com/cd/E19957-01/816-6402-10/url.htm
      #
      # rubocop:disable Lint/UriEscapeUnescape
      #
      # @api private
      class ENV

        extend Initializer

        param :connection,
              reader: true,
              type: Types::URI,
              default: -> { ::ENV.fetch('LDAPURI', default_connection) }

        param :config,
              reader: :private,
              type: Types::Strict::Hash,
              default: -> { EMPTY_OPTS }

        # Build LDAP URL with encoded spaces.
        #
        # @return [URI::LDAP, URI::LDAPS]
        #
        # @raise URI::InvalidURIError
        def uri
          URI(connection.gsub(SPACE, PERCENT_SPACE))
        end

        # Global search base. The value is derived in this order:
        #   1. Gateway Options
        #   2. ENVs
        #   3. URI (unless this is a socket) defaults ""
        #   4. an empty string
        #
        # @example
        #   'ldap://localhost/ou=users,dc=rom,dc=ldap' => ou=users,dc=rom,dc=ldap
        #
        # @return [String]
        #
        def base
          config.fetch(:base) do
            ::ENV['LDAPBASE'] || (path ? EMPTY_STRING : uri.dn.to_s)
          end
        end

        # Username and password.
        #
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
          { host: host, port: port, path: path, ssl: ssl, auth: auth }
        end

        # @return [String]
        #
        def inspect
          "<#{self.class.name} #{connection} />"
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

        # Override LDAPURI user with options or LDAPBINDDN.
        # Percent decode the URI's user value.
        #
        # @return [String, NilClass]
        #
        def bind_dn
          dn = config.fetch(:username, ::ENV['LDAPBINDDN']) || uri.user
          dn.gsub(PERCENT_SPACE, SPACE) if dn
        end
        # rubocop:enable Lint/UriEscapeUnescape

        # Override LDAPURI password with options or LDAPBINDPW
        #
        # @return [String, NilClass]
        #
        def bind_pw
          config.fetch(:password, ::ENV['LDAPBINDPW']) || uri.password
        end

        # LDAPHOST or localhost
        #
        # @return [String]
        #
        def default_host
          ::ENV.fetch('LDAPHOST', 'localhost')
        end

        # LDAPPORT or 389
        #
        # @return [Integer]
        #
        def default_port
          ::ENV.fetch('LDAPPORT', 389)
        end

        # Fallback connection scheme is "ldap://"
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
