RSpec.describe ROM::LDAP::Relation do

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


      view(:by_unit, %i[ou entry_uuid entry_parent_id]) do |ou|
        where(ou: ou).add_operational
      end

      view(:by_parent, %i[entry_dn entry_parent_id]) do |uuid|
        where(entry_parent_id: uuid).add_operational
      end

      view(:hidden_2) do
        # schema { append(relations[:tasks][:title]) }
        schema { project(:entry_uuid) }
        # schema { self }
        relation { add_operational }
      end


      def parent
        binding.pry
        id = add_operational.first[:entry_parent_id].first

        where(marketing[:entry_uuid].is(id))
      end

      # view(:hidden_3, schema.project(:entry_dn, :entry_uuid, :create_timestamp)) do
      #   order(:create_timestamp)
      # end
    end
  end

  subject(:relation) { relations[:marketing] }


  it '#to_a' do
    expect(relation).to respond_to(:to_a)
  end


  describe 'attributes' do

    before do
      relation.insert(
        dn: 'ou=marketing,ou=specs,dc=rom,dc=ldap',
        ou: 'marketing',
        object_class: 'organizationalUnit'
      )
    end

    after { relation.delete }

    it {
      expect(relation.schema.attributes.count).to eql(7)
      expect(relation.count).to eql(2)
      expect(relation.first.size).to eql(7)

      expect(relation.first.keys).to eql(
          %i[
            dn
            create_timestamp
            entry_dn
            entry_parent_id
            entry_uuid
            object_class
            ou
          ]
      )

    }
  end

end
