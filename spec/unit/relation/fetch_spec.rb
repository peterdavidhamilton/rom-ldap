RSpec.describe ROM::LDAP::Relation, '#fetch' do

  context 'with default primary_key' do

    include_context 'people'

    before do
      factories[:person, cn: 'Megatron', uid_number: 1]
      factories[:person, cn: 'Optimus', uid_number: 2]
    end

    it 'returns a single tuple' do
      expect(people.fetch('cn=Megatron,ou=specs,dc=rom,dc=ldap')[:uid_number]).to eql(1)
    end

    it 'raises when tuple was not found' do
      expect {
        people.fetch('uid=unknown,ou=spec,dc=rom,dc=ldap')
      }.to raise_error(ROM::TupleCountMismatchError, 'The relation does not contain any tuples')
    end

    it 'raises when more tuples are found' do
      expect {
        people.fetch(
          'cn=Megatron,ou=specs,dc=rom,dc=ldap',
          'cn=Optimus,ou=specs,dc=rom,dc=ldap'
        )
      }.to raise_error(ROM::TupleCountMismatchError, 'The relation consists of more than one tuple')
    end
  end


  context 'with custom primary_key' do
    before do
      conf.relation(:foo) do
        schema('(objectClass=inetOrgPerson)') do
          attribute :uid_number,
            ROM::LDAP::Types::Integer.meta(primary_key: true),
            read: ROM::LDAP::Types::Integer
        end
      end
    end

    include_context 'people'

    before do
      factories[:person, cn: 'Megatron', uid_number: 1]
      factories[:person, cn: 'Optimus', uid_number: 2]
    end

    let(:relation) { relations[:foo] }

    it 'returns a single tuple' do
      expect(relation.fetch(1)[:uid_number]).to eql(1)
    end

    it 'raises when tuple was not found' do
      expect {
        relation.fetch(5_315_412)
      }.to raise_error(ROM::TupleCountMismatchError, 'The relation does not contain any tuples')
    end

    it 'raises when more tuples are found' do
      expect {
        relation.fetch(1, 2)
      }.to raise_error(ROM::TupleCountMismatchError, 'The relation consists of more than one tuple')
    end
  end

end
