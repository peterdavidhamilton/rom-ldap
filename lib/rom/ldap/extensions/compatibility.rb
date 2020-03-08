# frozen_string_literal: true

require 'rom/ldap/functions'

module ROM
  module LDAP
    # Assign the formatting proc used to rename the Directory::Entry attributes.
    #
    use_formatter Functions[:to_method_name]
  end
end
