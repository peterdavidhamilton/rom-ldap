RSpec.describe ROM::LDAP::Relation, '#operational' do

  include_context 'factory'

  before do
    conf.relation(:marketing) do
      schema('(ou=*)') do
        attribute :ou,
          ROM::LDAP::Types::String, read: ROM::LDAP::Types::String
        attribute :object_class,
          ROM::LDAP::Types::Strings, read: ROM::LDAP::Types::Symbols
        attribute :entry_parent_id,
          ROM::LDAP::Types::String, read: ROM::LDAP::Types::String
        attribute :entry_dn,
          ROM::LDAP::Types::String, read: ROM::LDAP::Types::String
        attribute :entry_uuid,
          ROM::LDAP::Types::String, read: ROM::LDAP::Types::String

        use :timestamps,
          attributes: %i(create_timestamp modify_timestamp),
          type: ROM::LDAP::Types::Time

      end
    end
  end

  subject(:relation) { relations[:marketing] }


  before do
    relation.insert(
      dn: 'ou=marketing,ou=specs,dc=rom,dc=ldap',
      ou: 'marketing',
      object_class: 'organizationalUnit'
    )
  end

  after { relation.delete }

  with_vendors do

    it { expect(relation.schema.attributes.count).to eql(7) }

    it { expect(relation.count).to eql(2) }

    it 'user only' do
      expect(relation.first.size).to eql(3)
      expect(relation.first.keys).to eql(%i[dn object_class ou])
    end


    it '#first' do
      expect(relation.operational.first.keys).to include(
        *%i[
          dn
          create_timestamp
          creators_name
          object_class
          ou
        ]
      )
    end

    it '#to_a' do
      expect(relation.operational.to_a.first[:create_timestamp]).to be_a(Time)

      expect(relation.operational.to_a.first.keys).to include(
        *%i[
          create_timestamp
          object_class
          ou
        ]
      )
    end

  end

end
