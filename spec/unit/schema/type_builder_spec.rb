RSpec.describe ROM::LDAP::Schema::TypeBuilder do

  include_context 'dragons'

  describe 'coerces auto_struct attributes' do

    subject(:struct) { dragons.to_a.last }

    it 'to String' do
      expect(struct.fetch(:species)).to be_a(String)
    end

    it 'to Integer' do
      expect(struct.fetch(:population_count)).to be_a(Integer)
    end

    it 'to Time' do
      expect(struct.fetch(:create_timestamp)).to be_a(Time)
    end

    it 'to TrueClass or FalseClass' do
      expect(struct.fetch(:extinct)).to be_a(TrueClass)
      expect(struct.fetch(:endangered)).to be_a(FalseClass)
    end
  end


  describe 'builds LDAP schema into metadata' do

    let(:descriptions) do
      dragons.schema.to_h.values.map { |v|
        [v.name, v.type.meta[:description]]
      }.sort.to_h
    end

    it 'including the description for attributes' do
      expect(descriptions.fetch(:dn)).to eql(nil)
      expect(descriptions.fetch(:cn)).to eql("RFC2256: common name(s) for which the entity is known by")
      expect(descriptions.fetch(:entry_uuid)).to eql("UUID of the entry")
      expect(descriptions.fetch(:species)).to eql("The scientific name of the animal")
    end
  end
end
