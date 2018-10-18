require 'rom/associations/one_to_many'

module ROM
  module LDAP
    module Associations
      class OneToMany < ROM::Associations::OneToMany
        # @api public
        def call(*)
          # binding.pry
        end
      end
    end
  end
end
