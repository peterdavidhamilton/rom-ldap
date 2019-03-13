module ROM
  module LDAP
    # RedHat 389
    module ThreeEightNine
    end

    Directory.send(:include, ThreeEightNine)
  end
end
