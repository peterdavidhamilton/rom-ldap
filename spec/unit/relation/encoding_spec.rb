RSpec.describe ROM::LDAP::Relation, helpers: true do

  let(:formatter) { method_name_proc }

  include_context 'relations'

  describe '#where using non-utf8 encoded string' do
    before do
      accounts.insert(
        dn: 'cn=Bruce Lee,ou=users,dc=example,dc=com',
        uid: '李振藩',
        cn: 'Bruce Lee',
        given_name: 'Bruce',
        gid_number: 1,
        uid_number: 1973,
        sn: 'Lee',
        mail: 'dragon@example.com',
        object_class: %w[inetOrgPerson extensibleObject]
      )
    end

    after do
      relations[:accounts].by_pk('cn=Bruce Lee,ou=users,dc=example,dc=com').delete
      reset_attributes!
    end

    let(:relation) { relations[:accounts].where(uid: '李振藩') }

    it 'source filter' do
      expect(relation.source).to eql('(&(objectClass=person)(uid=*))')
    end

    it 'chained criteria' do
      expect(relation.query).to eql(
        [
          :con_and,
          [
            # original
            [
              :con_and,
              [
                [:op_eql, 'objectClass', 'person'],
                [:op_eql, 'uid', :wildcard]
              ]
            ],
            # criteria
            [:op_eql, :uid, '李振藩']
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql('(&(&(objectClass=person)(uid=*))(uid=李振藩))')
    end

    it 'result' do
      expect(relation.one[:uid]).to eql(['李振藩'])
    end
  end
end
