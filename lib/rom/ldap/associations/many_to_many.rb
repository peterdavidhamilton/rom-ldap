require 'rom/associations/many_to_many'

module ROM
  module LDAP
    module Associations
      class ManyToMany < ROM::Associations::ManyToMany
        # @api public
        def call(*)
          # binding.pry
        end
      end
    end
  end
end
