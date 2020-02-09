RSpec.describe ROM::LDAP::Schema, 'read type' do

  include_context 'factory'

  before do
    conf.relation(:specials) do
      schema('(objectClass=person)') do
        attribute :dn,            ROM::LDAP::Types::String
        attribute :cn,            ROM::LDAP::Types::String
        attribute :object_class,  ROM::LDAP::Types::Strings
        attribute :sn,            ROM::LDAP::Types::String
        attribute :user_password, ROM::LDAP::Types::String

        attribute :jpeg_photo,
          ROM::LDAP::Types::Binary,
          read: ROM::LDAP::Types::Media
      end
      auto_struct true
    end

    factories.define(:special) do |f|
      f.sequence(:cn) { |n| "User #{n}" }
      f.dn { |cn| "cn=#{cn},ou=specs,dc=rom,dc=ldap" }
      f.object_class %w[person inetorgperson extensibleobject]
      f.sn 'Lastname'
      f.user_password 'password'
      f.jpeg_photo File.read("#{SPEC_ROOT}/fixtures/pixel.jpg")
    end
  end

  let(:specials) { relations[:specials] }

  after { specials.delete }

  with_vendors do

    it 'ROM::LDAP::Types::Media' do
      factories[:special]

      expect(specials.one.jpeg_photo).to eql("data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAMCAgICAgMCAgIDAwMDBAYEBAQEBAgGBgUGCQgKCgkICQkKDA8MCgsOCwkJDRENDg8QEBEQCgwSExIQEw8QEBD/wAALCAABAAEBAREA/8QAFAABAAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/2gAIAQEAAD8AVN//2Q==")
    end
  end


end
