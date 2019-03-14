module ROM
  module LDAP
    IGNORE_ATTRS_REGEX = /^[m-|ads|entry].*$/.freeze

    # Apache Directory Server
    module ApacheDS

      # TODO: default development env stuff?
    end

    Directory.send(:include, ApacheDS)
  end
end
