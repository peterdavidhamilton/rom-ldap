RSpec.describe ROM::LDAP::Schema do

  describe '#primary_keys' do
    it 'returns primary key attributes' do
      schema_proc = Class.new(ROM::Relation[:ldap]).schema do
        attribute :dn, ROM::LDAP::Types::String.meta(primary_key: true)
        attribute :id, ROM::LDAP::Types::Integer.meta(primary_key: true)
      end

      schema = schema_proc.call
      schema.finalize_attributes!.finalize!

      expect(schema.primary_key).to eql([schema[:dn], schema[:id]])
    end

    it 'returns empty array when there is no PK defined' do
      schema_proc = Class.new(ROM::Relation[:ldap]).schema do
        attribute :id, ROM::LDAP::Types::Integer
      end

      schema = schema_proc.call
      schema.finalize_attributes!.finalize!

      expect(schema.primary_key).to eql([])
    end
  end

end
