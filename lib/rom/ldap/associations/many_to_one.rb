require 'rom/associations/many_to_one'

module ROM
  module LDAP
    module Associations
      class ManyToOne < ROM::Associations::ManyToOne

        # @api public
        def call(*)
          binding.pry
        end

      end
    end
  end
end
