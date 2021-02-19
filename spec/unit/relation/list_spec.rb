RSpec.describe ROM::LDAP::Relation, '#list' do

  include_context 'people'

  before do
    5.times { factories[:person, :sequence] }
  end

  with_vendors do

    context 'structs' do
      subject(:relation) { people.with(auto_struct: true).order(:uid_number) }

      it 'as flat array of coerced values' do
        expect(relation.list(:uid)).to eql(%w[user1 user2 user3 user4 user5])
        expect(relation.list(:uid_number)).to eql([1, 2, 3, 4, 5])
      end

      it 'raises error using canonical attribute names' do
        expect { relation.list(:uidNumber) }.to raise_error(ROM::Struct::MissingAttribute, /uidNumber/)
      end

      it 'raises error on missing attributes' do
        expect { relation.list(:foo) }.to raise_error(ROM::Struct::MissingAttribute, /foo/)
      end
    end



    context 'hashes' do
      subject(:relation) { people.with(auto_struct: false).order(:uid_number) }

      it 'as flat array of strings' do
        expect(relation.list(:uid)).to eql(%w[user1 user2 user3 user4 user5])
        expect(relation.list(:uid_number)).to eql(%w[1 2 3 4 5])
      end

      it 'accepts canonical attribute names' do
        expect(relation.list(:uidNumber)).to eql(%w[1 2 3 4 5])
      end

      it 'returns empty for missing attributes' do
        expect(relation.list(:foo)).to eql([])
      end
    end
  end

end
