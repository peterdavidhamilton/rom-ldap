# encoding: utf-8
# frozen_string_literal: true

require 'dragonfly'

module ROM
  module Ldap
    class Relation < ROM::Relation
      module Writing

        # Wrapper for net-ldap modify method
        #
        # @api public
        def update(dn, attrs)
          if image?(attrs)
            binding.pry
            directory.modify(dn: dn, attributes: attrs.except(options[:image]))
            upload_image(dn, attrs.fetch(options[:image]))
          else
            directory.modify(dn: dn, attributes: attrs)
          end
        end

        # Wrapper for net-ldap add method
        #
        # @api public
        def create(dn, attrs)
          if image?(attrs)
            directory.add(dn: dn, attributes: attrs)
            upload_image(dn, attrs.fetch(options[:image]))
          else
            directory.add(dn: dn, attributes: attrs)
          end
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
        def upload_image(dn, url)
          payload = get_image_as_utf8_string(url)
          directory.replace_attribute(dn, :jpegphoto, payload)
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
              raise 'Unknown url'
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
