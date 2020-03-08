# frozen_string_literal: true

require 'digest/sha1'
require 'digest/sha2'
require 'digest/md5'
require 'base64'
require 'securerandom'

# sha2-512 512bit or 64bytes
# sha 160bits or 20bytes
#
module ROM
  module LDAP
    class Directory

      # @abstract
      #   Encode and validate passwords using md5, sha or ssha.
      #
      # @api public
      class Password

        # Generate an ecrypted password.
        #
        # @example
        #   Password.generate(:ssha, 'secret magic word')
        #
        # @param type     [Symbol] Encryption type. [:md5, :sha, :ssha].
        # @param password [String] Plain text password to be encrypted.
        #
        # @return [String]
        #
        # @raise [PasswordError]
        #
        # @api public
        def self.generate(type, password, salt = secure_salt)
          raise PasswordError, 'No password supplied' if password.nil?

          case type
          when :md5    then _encode(type, md5(password))
          when :sha    then _encode(type, sha(password))
          when :ssha   then _encode(type, ssha(password, salt))
          when :ssha512 then _encode(type, ssha512(password, salt))
          else
            raise PasswordError, "Unsupported encryption type (#{type})"
          end
        end

        def self.check_ssha512(password, encrypted)
          decoded = Base64.decode64(encrypted.gsub(/^{SSHA512}/, EMPTY_STRING))
          # hash = decoded[0..64]
          salt = decoded[64..-1]
          _encode(:ssha512, ssha512(password, salt)) == encrypted
        end

        # Validate plain password against encrypted SSHA password.
        #
        # @return [TrueClass, FalseClass]
        #
        # @api public
        def self.check_ssha(password, encrypted)
          decoded = Base64.decode64(encrypted.gsub(/^{SSHA}/, EMPTY_STRING))
          # hash = decoded[0..20]
          salt = decoded[20..-1]
          _encode(:ssha, ssha(password, salt)) == encrypted
        end

        private_class_method

        # @return [String] Prepend type to encrypted string.
        #
        # @api private
        def self._encode(type, encrypted)
          "{#{type.upcase}}" + Base64.strict_encode64(encrypted).chomp
        end

        # Generate salt.
        #
        # @api private
        def self.secure_salt
          SecureRandom.random_bytes(16)
        end

        # @param str [String]
        #
        # @return [String] MD5 digest.
        #
        # @api private
        def self.md5(str)
          Digest::MD5.digest(str)
        end

        # @param str  [String]
        # @param salt [String]
        #
        # @return [String] SHA1 digest with salt.
        #
        # @api private
        def self.ssha(str, salt)
          Digest::SHA1.digest(str + salt) + salt
        end

        # @param str [String]
        #
        # @return [String] SHA1 digest without salt.
        #
        # @api private
        def self.sha(str)
          Digest::SHA1.digest(str)
        end

        # "{SSHA512}A1lCCGYzUEJ5/qQCrFUAztLVaTaWv959RnpzaOsWB9Ij4CBCeNh6i4XrZzrvwUMM/AWbEb8Gjc7FWOBSPnkRuHsexjzeQImm"
        # initial
        #
        def self.ssha512(str, salt)
          Digest::SHA512.digest(str + salt) + salt
        end

      end

    end
  end
end
