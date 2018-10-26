#
# Use new wildlife data
#
RSpec.describe ROM::LDAP::Schema::TypeBuilder, helpers: true do

  let(:formatter) { nil }

  include_context 'directory'

  before do
    use_formatter(formatter)

    conf.relation(:wildlife) do
      schema('(species=*)', infer: true)
      base 'ou=animals,dc=example,dc=com'
    end
  end

  after(:each) do
    reset_attributes!
  end

  let(:relation) { relations.wildlife }
  let(:schema)   { relation.schema.to_h }

  # zebra
  subject(:account) { relation.to_a.last }

  describe 'coerces' do
    it 'integer values' do
      expect(account.fetch('populationCount')).to eql(0)
    end

    it 'time values' do
      expect(account.fetch('createTimestamp').class).to eql(Time)
    end

    it 'boolean values' do
      expect(account.fetch('extinct')).to eql(false)
    end
  end


  describe 'builds LDAP schema into metadata' do

    let(:description) do
      schema.values.map { |v| [v.name, v.type.meta[:description]] }.to_h
    end

    it 'including the description for attributes' do
      expect(description.fetch('dn')).to eql(nil)
      expect(description.fetch('cn')).to eql("RFC2256: common name(s) for which the entity is known by")
      expect(description.fetch('entryUUID')).to eql("UUID of the entry")
      expect(description.fetch('species')).to eql("The scientific name of the animal")
    end
  end
end
