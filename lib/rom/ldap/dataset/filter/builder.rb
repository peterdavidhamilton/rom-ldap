require 'dry-types'
require 'dry-initializer'

require 'rom/ldap/dataset/filter'
require 'rom/ldap/dataset/filter/builder/class_methods'
require 'rom/ldap/dataset/filter/builder/instance_methods'

module ROM
  module LDAP
    class Dataset
      module Filter
        # Replacement for Net::LDAP::Filter
        #
        # @api private
        class Builder

          METHODS = [:ne, :eq, :ge, :le, :and, :or, :not, :ex, :bineq].freeze

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
end
