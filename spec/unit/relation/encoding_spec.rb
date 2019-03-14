RSpec.describe ROM::LDAP::Relation, 'encoding' do

  include_context 'people'

  describe 'using non-utf8 values' do

    before do
      factories[:person,
        uid: '李振藩',
        cn: 'Bruce Lee',
        given_name: 'Bruce',
        gid_number: 1,
        uid_number: 1973,
        sn: 'Lee',
        mail: 'dragon@example.com',
        object_class: %w[inetOrgPerson extensibleObject]
      ]
    end

    let(:relation) { people.where(uid: '李振藩'.encode!('eucJP')) }

    it 'returns utf8 values' do
      expect(relation.one[:uid]).to eql(['李振藩'])
    end
  end
end
