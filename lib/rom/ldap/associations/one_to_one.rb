require 'rom/ldap/associations/one_to_many'

module ROM
  module LDAP
    module Associations
      class OneToOne < OneToMany

        # @api public
        def call(*)
          # binding.pry
          super
        end

      end
    end
  end
end
