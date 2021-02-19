# frozen_string_literal: true

require 'rom/initializer'
require 'libxml'

module ROM
  module LDAP
    #
    # Directory Service Markup Language (DSML)
    #
    # Refines Array and Hash with #to_dsml method.
    #
    # @see https://publib.boulder.ibm.com/tividd/td/ITIM/SC32-1149-01/en_US/HTML/Policy_Org_Admin395.htm
    # @see Directory::Entry
    # @see Relation::Exporting
    #
    module DSML
      # Export Entry objects as DSML files.
      #
      # @param tuple [Entry]
      #
      # @api private
      class Exporter

        extend Initializer

        include LibXML

        # Dataset
        #
        param :tuples, type: Types::Strict::Array.of(Types::Strict::Hash)

        #   <?xml version="1.0" encoding="UTF-8"?>
        #   <dsml>
        #     <directory-entries>
        #       <entry dn="dn">
        #
        # @return [String]
        #
        # @api private
        def to_dsml
          doc = XML::Document.new
          doc.encoding = XML::Encoding::UTF_8
          doc.root = root = create_node('dsml')
          root << (entries = create_node('directory-entries'))
          map_tuples { |entry| entries << entry }
          doc.to_s
        end

        private

        # <entry dn="dn">
        #
        # @yield [LibXML::XML::Node]
        #
        def map_tuples
          tuples.each do |tuple|
            next if tuple.empty?

            dn   = tuple.delete('dn')
            objc = tuple.delete('objectClass')

            entry_node = create_node('entry', dn: dn&.first)

            classes(objc) { |c| entry_node << c }

            attributes(tuple) { |a| entry_node << a }

            yield(entry_node)
          end
        end

        # Returns "<objectclass/>" if param is nil
        #
        # <oc-value>inetOrgPerson</oc-value>
        #
        # @param [Array, Nil] values
        #
        # @yield [LibXML::XML::Node]
        #
        def classes(values)
          class_node = create_node('objectclass')
          values.to_a.each do |value|
            value_node = create_node('oc-value')
            value_node.content = value
            class_node << value_node
          end
          yield(class_node)
        end

        # @example
        #
        #   {'cn'=>['Peter']}
        #     => <attr name="cn"><value>Peter</value></attr>
        #
        # @yield [LibXML::XML::Node]
        #
        def attributes(attrs)
          attrs.each do |attr_name, attr_values|
            attr_node = create_node('attr', name: attr_name)
            attr_values.each do |value|
              value_node = create_node('value')
              value_node.content = value
              attr_node << value_node
            end
            yield(attr_node)
          end
        end

        #
        # @return [LibXML::XML::Node]
        #
        def create_node(type, params = EMPTY_OPTS)
          node = XML::Node.new(type)
          unless params.empty?
            params.each do |key, value|
              XML::Attr.new(node, key.to_s, value.to_s)
            end
          end
          node
        end

      end

      # Extend functionality of Hash class.
      #
      refine ::Hash do
        # Convert hash to DSML format
        #
        # @return [String]
        #
        # @api public
        def to_dsml
          Exporter.new([self]).to_dsml
        end
      end

      # Extend functionality of Array class.
      #
      refine ::Array do
        # Convert array to DSML format
        #
        # @return [String]
        #
        # @api public
        def to_dsml
          Exporter.new(self).to_dsml
        end
      end
    end

    module DSMLExport
      using DSML
      #
      # @return [String]
      #
      # @api public
      def to_dsml
        export.to_dsml
      end
    end

    Relation.include DSMLExport
  end
end
