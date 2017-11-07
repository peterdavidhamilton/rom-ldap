module ROM
  module LDAP
    class Directory
      begin
        require 'moneta'

        CACHE = Moneta.build do
          use :Expires,     expires: 300
          use :Transformer, key: %i[marshal base64], value: :marshal
          adapter :Memory
        end
      rescue LoadError
      end
    end
  end
end
