# frozen_string_literal: true

require 'yaml'
require 'pathname'

module ROM
  module LDAP
    #
    # Loaded by PDU
    #
    # @see https://tools.ietf.org/html/rfc4511#section-4.1.9
    #
    RESPONSES_PATH = Pathname(__dir__).join('../../../config/responses.yml').realpath.freeze

    RESPONSES = ::YAML.load_file(RESPONSES_PATH).freeze
  end
end
