RSpec.describe ROM::LDAP::Schema::Inferrer do

  describe 'interprets directory.attribute_types in to ruby classes' do
    let(:formatter) { method_name_proc }

    include_context 'relations'

    subject(:schema) { accounts.schema.to_h }

    it "has loaded the directory's schema" do
      expect(accounts.dataset.directory.attribute_types).to_not be_empty
    end

    it 'has formatted attribute names' do
      expect(schema.keys).to include(
        *%i[
          apple_imhandle
          cn
          create_timestamp
          creators_name
          dn
          entry_csn
          entry_dn
          entry_parent_id
          entry_uuid
          gid_number
          given_name
          mail
          nb_children
          nb_subordinates
          object_class
          pwd_history
          sn
          subschema_subentry
          uid
          uid_number
          user_password
        ]
      )
    end

    it 'has inferred attribute types' do
      primitives = schema.values.map { |v| v.type.primitive.name }.uniq
      expect(primitives).to eql(%w[String Time Array Integer])
    end
  end
end
