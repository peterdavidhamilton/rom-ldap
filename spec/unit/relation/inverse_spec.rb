RSpec.describe ROM::LDAP::Relation, '#inverse' do

  include_context 'animals'

  before do
    factories[:animal, cn: 'foofoofoo']
    factories[:animal, genus: 'barbarbar']
    factories[:animal, species: 'bazbazbaz']
  end

  describe 'of exact match' do
    let(:relation) { animals.where(cn: 'foofoofoo', species: 'bazbazbaz').inverse }

    it  do
      expect(relation.count).to eql(1)
      expect(relation.one[:genus]).to eql('barbarbar')
    end
  end


  describe 'of fuzzy match' do
    let(:relation) { animals.matches(species: 'baz', cn: 'foo').inverse }

    it do
      expect(relation.count).to eql(1)
      expect(relation.last[:genus]).to eql(%w'barbarbar')
    end
  end

end
