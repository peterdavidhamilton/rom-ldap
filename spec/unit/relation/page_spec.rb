RSpec.describe ROM::LDAP::Relation, 'paging' do

  include_context 'people'

  before do
    10.times do
      factories[:person]
    end
  end

  subject(:relation) { people.with(auto_struct: true).order(:uid) }


  describe '#total' do
    before { 200.times { factories[:person] } }
    after { people.delete }

    it 'is unlimited' do
      # expect(relation.count).to eql(10)
      expect(relation.total).to eql(210)
    end
  end
end
