module ROM
  module LDAP

    begin
      require 'moneta'

      CACHE = Moneta.build do
        use :Expires
        use :Transformer, key: [:marshal, :base64], value: :marshal
        adapter :Memory
      end

    rescue LoadError
    end

  end
end
