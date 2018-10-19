require 'dry/core/extensions'

module ROM
  module LDAP
    extend Dry::Core::Extensions

    register_extension(:compatible_entry_attributes) do
      require 'rom/ldap/extensions/compatible_entry_attributes'
    end

    register_extension(:active_support_notifications) do
      require 'rom/sql/extensions/active_support_notifications'
    end

    register_extension(:rails_log_subscriber) do
      require 'rom/sql/extensions/rails_log_subscriber'
    end

    #=======================================
    # Vendors
    #=======================================

    register_extension(:active_directory) do
      require 'rom/ldap/extensions/active_directory'
    end

    register_extension(:open_directory) do
      require 'rom/ldap/extensions/open_directory'
    end

    register_extension(:e_directory) do
      require 'rom/ldap/extensions/e_directory'
    end

    register_extension(:apache_ds) do
      require 'rom/ldap/extensions/apache_ds'
    end

    register_extension(:three_eight_nine) do
      require 'rom/ldap/extensions/three_eight_nine'
    end
  end
end
