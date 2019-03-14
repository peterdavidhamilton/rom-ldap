require 'yaml'
require 'pathname'

module ROM
  module LDAP
    #
    # Loaded by PDU
    #
    # @see https://tools.ietf.org/html/rfc4511#section-4.1.9
    #
    RESPONSES = ::YAML.load_file(Pathname(__FILE__).dirname.join('responses.yaml')).freeze
  end
end
