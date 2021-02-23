RSpec.describe ROM::LDAP::Relation, '#by_pk' do

 context 'defaults to DN' do
    include_context 'people'

    with_vendors do
      before do
        factories[:person, cn: 'He-Man', uid_number: 1]
        factories[:person, cn: 'Skeletor', uid_number: 2]
      end


      it '#by_pk' do
        expect(people.by_pk('cn=He-Man,ou=specs,dc=rom,dc=ldap').one[:uid_number]).to eql(1)
        expect(people.with(auto_struct: true).by_pk('cn=Skeletor,ou=specs,dc=rom,dc=ldap').one.cn).to eql(['Skeletor'])
      end
    end
  end



  context 'works with other attributes' do
    before do
      conf.relation(:foo) do
        schema('(objectClass=inetOrgPerson)') do
          attribute :cn, ROM::LDAP::Types::String

          attribute :uid_number,
            ROM::LDAP::Types::Integer.meta(primary_key: true),
            read: ROM::LDAP::Types::Integer
        end
      end
    end

    include_context 'people'

    with_vendors do
      before do
        factories[:person, cn: 'Liono', uid_number: 1]
        factories[:person, cn: 'Snarf', uid_number: 2]
      end

      let(:relation) { relations[:foo] }

      it 'returns a single tuple' do
        expect(relation.by_pk(1).one[:uid_number]).to eql(1)
        expect(relation.by_pk(2).one[:cn]).to eql('Snarf')
      end
    end

  end
end
