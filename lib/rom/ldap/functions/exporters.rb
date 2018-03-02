require 'rom/ldap/functions/query_exporter'
require 'rom/ldap/functions/filter_exporter'
require 'rom/ldap/functions/expression_exporter'

module ROM
  module LDAP
    module Functions
      # Module methods for Functions
      #
      module Exporters
        private

        def query
          @composer ||= QueryExporter.new
        end

        def filter
          @decomposer ||= FilterExporter.new
        end

        def expression
          @parser ||= ExpressionExporter.new
        end
      end
    end
  end
end
