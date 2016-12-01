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
          if image_attribute?(attrs)
            txt = without_image(attrs)
            binding.pry
            directory.add(dn: dn, attributes: txt)
            upload_image(dn, attrs)
          else
            directory.add(dn: dn, attributes: attrs)
          end
        end

        # ops = [
        #   [:add, :mail, "aliasaddress@example.com"],
        #   [:replace, :mail, ["old", "new"]],
        #   [:delete, :jpegphoto, nil]
        # ]
        def bulk_update(dn, ops)
          directory.modify(dn: dn, operations: ops)
        end


        # Wrapper for net-ldap modify method
        #
        # @api public
        def update(dn, attrs)
          if image_attribute?(attrs)
            txt = without_image(attrs)
            directory.modify(dn: dn, attributes: txt)
            upload_image(dn, attrs)
          else
            directory.modify(dn: dn, attributes: attrs)
          end
        end

        # Wrapper for net-ldap delete method
        #
        # @api public
        def delete(dn)
          directory.delete(dn: dn)
        end

        private

        # Check whether submitted attributes include the jpegphoto key
        #
        # @api private
        def image_attribute?(attrs)
          attrs.key?(options[:image])
        end

        def without_image(attrs)
          attrs.except(options[:image])
        end

        def just_image(attrs)
          attrs.fetch(options[:image])
        end

        # Change jpegphoto attribute using a file's fully qualified path
        #
        # @api private
        def upload_image(dn, attrs)
              url = just_image(attrs)
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
