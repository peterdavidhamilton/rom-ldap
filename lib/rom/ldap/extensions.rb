# frozen_string_literal: true

require 'dry/core/extensions'

module ROM
  module LDAP
    extend Dry::Core::Extensions

    # Make entry attributes suitable method names.
    #
    register_extension(:compatibility) do
      require 'rom/ldap/extensions/compatibility'
    end

    #=======================================
    # Exporters
    #=======================================

    # Add #to_dsml method to relation instance.
    #
    register_extension(:dsml_export) do
      require 'rom/ldap/extensions/dsml'
    end

    # Add #to_msgpack method to relation instance.
    #
    register_extension(:msgpack_export) do
      require 'rom/ldap/extensions/msgpack'
    end

    # Patch #to_json method in relation instance.
    #
    register_extension(:oj_export) do
      require 'rom/ldap/extensions/optimised_json'
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
  end
end
