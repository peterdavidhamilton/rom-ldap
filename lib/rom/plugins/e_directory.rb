module ROM
  module LDAP
    # Novell eDirectory
    module EDirectory
      NETWARE_SERVERS = '(objectClass=ncpServer)'.freeze
      NETWARE_VOLUMES = '(objectClass=volume)'.freeze
      ZEN_APPLICATION = '(objectClass=appApplication)'.freeze
    end
  end
end
