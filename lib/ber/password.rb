require 'digest/sha1'
require 'digest/md5'
require 'base64'
require 'securerandom'

module BER
  class Password
    def self.generate(type, password)
      salt = secure_salt

      case type
      when :md5  then encode(type, md5(password))
      when :sha  then encode(type, sha(password))
      when :ssha then encode(type, ssha(password, salt))
      else
        raise Error, "Unsupported password-hash type (#{type})"
      end
    end

    private

    def self.encode(type, encrypted)
      "{#{type.upcase}}" + Base64.encode64(encrypted).chomp!
    end

    def self.secure_salt
      SecureRandom.random_bytes(16)
    end

    def self.md5(str)
      Digest::MD5.digest(str)
    end

    def self.ssha(str, salt)
      Digest::SHA1.digest(str + salt) + salt
    end

    def self.sha(str)
      Digest::SHA1.digest(str)
    end
  end
end
