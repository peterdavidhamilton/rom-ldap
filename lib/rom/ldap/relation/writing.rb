# encoding: utf-8
# frozen_string_literal: true

module ROM
  module Ldap
    class Relation < ROM::Relation
      module Writing

        # Wrapper for net-ldap add method
        #
        # @api public
        def create(dn, attrs)
          directory.add(dn: dn, attributes: attrs.except(options[:image]))
          upload_image(dn, attrs) if attrs.key?(options[:image])
          # op_status.message
        end

        # Wrapper for net-ldap modify method
        #
        # @api public
        def update(dn, attrs)
          directory.modify(dn: dn, attributes: attrs.except(options[:image]))
          upload_image(dn, attrs) if attrs.key?(options[:image])
        end

        # ops = [
        #   [:add, :mail, "aliasaddress@example.com"],
        #   [:replace, :mail, ["old", "new"]],
        #   [:delete, :jpegphoto, nil]
        # ]
        def bulk_update(dn, ops)
          directory.modify(dn: dn, operations: ops)
        end

        # Wrapper for net-ldap delete method
        #
        # @api public
        def delete(dn)
          directory.delete(dn: dn)
        end

        private

        # Change jpegphoto attribute using a file's fully qualified path
        #
        # @api private
        def upload_image(dn, attrs)
              url = attrs.fetch(options[:image])
          payload = get_image_as_utf8_string(url)

          directory.replace_attribute(dn, options[:image], payload)
        end

        # Use Dragonfly to prepare image data from URL
        #
        # @api private
        def get_image_as_utf8_string(url)
          file = ->(url) do
            case url.split(':').first
            when 'http'  then processor.fetch_url(url)
            when 'https' then processor.fetch_url(url)
            when 'file'  then processor.fetch_file(url)
            else
              adapter.logger.debug 'unknown url'
            end
          end

          file[url].encode('jpg').data.force_encoding('utf-8')
        end

        def processor
          Dragonfly.app
        end
      end
    end
  end
end
