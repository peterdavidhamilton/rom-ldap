RSpec.describe ROM::LDAP::Relation, '#rename' do

  include_context 'people'

  with_vendors  do

    before do
      factories[:person, uid: 'tom', cn: 'bill bob']
    end

    subject(:relation) do
      people.with(auto_struct: true).rename(uid: :user_id, cn: :display_name)
    end

    it 'aliases in schema' do
      expect(relation.schema.map(&:alias)).to include(:user_id, :display_name)
    end

    it 'renames entry attributes' do
      expect(relation.first).to include(user_id: ['tom'])
      expect(relation.one).to include(display_name: ['bill bob'])
    end

  end

end
