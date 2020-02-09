# frozen_string_literal: true

module ROM
  module LDAP
    # Type Builder
    #
    # @see https://ldap.com/matching-rules/
    #
    # Matching Rules - 2.5.13
    #
    # @return [Array<String>]
    #
    # @api private
    STRING_MATCHERS = %w[
      2.5.13.0 objectIdentifierMatch
      2.5.13.1 distinguishedNameMatch
      2.5.13.2 caseIgnoreMatch
      2.5.13.3 caseIgnoreOrderingMatch
      2.5.13.4 caseIgnoreSubstringsMatch
      2.5.13.5 caseExactMatch
      2.5.13.6 caseExactOrderingMatch
      2.5.13.7 caseExactSubstringsMatch
      2.5.13.8 numericStringMatch
      2.5.13.9 numericStringOrderingMatch
      2.5.13.10 numericStringSubstringsMatch
      2.5.13.11 caseIgnoreListMatch
      2.5.13.12 caseIgnoreListSubstringsMatch
      2.5.13.17 octetStringMatch
      2.5.13.18 octetStringOrderingMatch
      2.5.13.20 telephoneNumberMatch
      2.5.13.21 telephoneNumberSubstringsMatch
      2.5.13.24 protocolInformationMatch
      2.5.13.30 objectIdentifierFirstComponentMatch

      1.3.6.1.1.16.2 uuidMatch
      1.3.6.1.1.16.3 uuidOrderingMatch

      1.3.6.1.4.1.1466.109.114.1 caseExactIA5Match
      1.3.6.1.4.1.1466.109.114.2 caseIgnoreIA5Match
      1.3.6.1.4.1.1466.109.114.3 caseIgnoreIA5SubstringsMatch
    ].freeze

    # @return [Array<String>]
    #
    # @api private
    BOOLEAN_MATCHERS = %w[
      2.5.13.13 booleanMatch
    ].freeze

    #
    # @return [Array<String>]
    #
    # @api private
    INTEGER_MATCHERS = %w[
      2.5.13.14 integerMatch
      2.5.13.15 integerOrderingMatch
    ].freeze

    # @return [Array<String>]
    #
    # @api private
    TIME_MATCHERS = %w[
      csnMatch
      2.5.13.25 uTCTimeMatch
      2.5.13.27 generalizedTimeMatch
      2.5.13.28 generalizedTimeOrderingMatch
    ].freeze
  end
end
