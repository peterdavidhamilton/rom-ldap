require 'dry-types'
require 'dry-initializer'

require 'rom/ldap/filter'
require 'rom/ldap/filter/builder/class_methods'
require 'rom/ldap/filter/builder/instance_methods'

module ROM
  module LDAP
    module Filter
      # @api private
      class Builder
        METHODS = %i[
          ne eq ge le ex bineq
          present parse_ber construct
          join and
          intersect or
          negate not
        ].freeze

        extend ClassMethods

        extend Dry::Initializer

        param :op,    reader: :private, type: Dry::Types['strict.symbol']
        param :left,  reader: :private
        param :right, reader: :private, optional: true

        include InstanceMethods
      end
    end
  end
end
