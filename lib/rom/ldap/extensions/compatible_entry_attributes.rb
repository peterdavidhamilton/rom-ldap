require 'rom/ldap/functions'
require 'rom/ldap/directory/entry'

module ROM
  module LDAP
    # Assign the formatting proc used to rename the Directory::Entry attributes.
    #
    # Use the #to_method_name function
    #
    formatter_proc = lambda do |key|
      Functions.to_method_name(key)
    end

    Directory::Entry.use_formatter(formatter_proc)
  end
end
