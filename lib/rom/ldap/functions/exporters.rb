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
          @query ||= QueryExporter.new
        end

        def filter
          @filter ||= FilterExporter.new
        end

        def expression
          @expression ||= ExpressionExporter.new
        end
      end
    end
  end
end
