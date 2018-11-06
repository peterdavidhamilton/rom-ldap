RSpec.describe ROM::LDAP::Schema::Inferrer do

  include_context 'dragons'

  describe 'interprets directory.attribute_types into ruby classes' do

    it "has loaded the directory's schema" do
      expect(dragons.dataset.directory.attribute_types).to_not be_empty
    end

    it 'has formatted attribute names' do
      expect(dragons.schema.to_h.keys).to include(
        *%i[
          cn
          create_timestamp
          creators_name
          dn
          entry_csn
          entry_dn
          entry_parent_id
          entry_uuid
          nb_children
          nb_subordinates
          object_class
          species
          subschema_subentry
        ]
      )
    end

    it 'has inferred attribute types' do
      primitives = dragons.schema.to_h.values.map { |v| v.type.primitive.name }.uniq.sort
      expect(primitives).to eql(['Array', 'Integer', 'String', 'Time', 'TrueClass | FalseClass'])
    end
  end
end
