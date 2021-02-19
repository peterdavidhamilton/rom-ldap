# frozen_string_literal: true

module ROM
  module LDAP
    # The major version of ROM-LDAP. Only bumped for major changes.
    MAJOR = 0

    # The minor version of ROM-LDAP. Bumped for every non-patch level release.
    MINOR = 2

    # The tiny version of ROM-LDAP. Only bumped for bugfix releases.
    TINY  = 1

    # The version of ROM-LDAP, as a string (e.g. "2.11.0")
    VERSION = [MAJOR, MINOR, TINY].join('.').freeze
  end
end
