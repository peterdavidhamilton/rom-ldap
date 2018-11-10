RSpec.describe ROM::LDAP::Relation do

  before { skip('awaiting redesign') }

  include_context 'people'

  describe '#where using non-utf8 encoded string' do

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

    it 'source filter' do
      expect(relation.source_filter).to eql('(objectClass=person)')
    end

    it 'chained criteria' do
      expect(relation.query_ast).to eql(
        [
          :con_and,
          [
            # original
            [:op_eql, 'objectClass', 'person'],
            # criteria
            [:op_eql, :uid, '李振藩']
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.ldap_string).to eql('(&(objectClass=person)(uid=李振藩))')
    end

    it 'result' do
      expect(relation.one[:uid]).to eql(['李振藩'])
    end
  end
end
