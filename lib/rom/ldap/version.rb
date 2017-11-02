module ROM
  module LDAP
    def self.root
      Pathname(File.dirname(__dir__))
    end

    VERSION = '0.0.6'.freeze
  end
end
