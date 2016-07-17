module ROM
  module Ldap
    class Relation < ROM::Relation
      module Writing



        def edit(dn, tuple)
          directory.modify(dn: dn, attributes: tuple)
        end

        def insert(dn, tuple)
          directory.add(dn: dn, attributes: tuple)
        end

        def delete(dn)
          directory.delete(dn: dn)
        end




        def add_image(dn, url)
          payload = get_image_as_utf8_string(url)
          directory.replace_attribute(dn, :jpegphoto, payload)
        end

        private

        # TODO: extract dragonfly processer object
        def get_image_as_utf8_string(url)
          file = ->(url) do
            processor = Toolbox::Container['assets.processor']

# uri = URI.parse(url)
# uri.scheme

# if URI.regexp(['file'])

# else


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
      end
    end
  end
end
