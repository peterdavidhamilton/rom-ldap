require 'dry/core/extensions'

module ROM
  module LDAP
    extend Dry::Core::Extensions

    register_extension(:compatibility) do
      require 'rom/ldap/extensions/compatibility'
    end

    #=======================================
    # Exporters
    #=======================================

    register_extension(:dsml_export) do
      require 'rom/ldap/extensions/exporters/dsml'
    end

    register_extension(:msgpack_export) do
      require 'rom/ldap/extensions/exporters/msgpack'
    end

    #=======================================
    # Autoloaded for Rails
    #=======================================

    register_extension(:active_support_notifications) do
      require 'rom/ldap/extensions/active_support_notifications'
    end

    register_extension(:rails_log_subscriber) do
      require 'rom/ldap/extensions/rails_log_subscriber'
    end

    #=======================================
    # Autoloaded by vendor
    #
    # Extends directory only ATM
    #=======================================

    register_extension(:open_ldap) do
      require 'rom/ldap/extensions/vendors/open_ldap'
    end

    register_extension(:active_directory) do
      require 'rom/ldap/extensions/vendors/active_directory'
    end

    register_extension(:open_directory) do
      require 'rom/ldap/extensions/vendors/open_directory'
    end

    register_extension(:open_dj) do
      require 'rom/ldap/extensions/vendors/open_dj'
    end

    register_extension(:e_directory) do
      require 'rom/ldap/extensions/vendors/e_directory'
    end

    register_extension(:apache_ds) do
      require 'rom/ldap/extensions/vendors/apache_ds'
    end

    register_extension(:three_eight_nine) do
      require 'rom/ldap/extensions/vendors/three_eight_nine'
    end
  end
end
