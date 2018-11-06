RSpec.describe ROM::LDAP::Relation, '#fetch' do

  context 'with default primary_key' do

    include_context 'people'

    before do
      factories[:person, cn: 'Megatron', uid_number: 1]
      factories[:person, cn: 'Optimus', uid_number: 2]
    end

    # after do
    #   people.where(cn: 'Megatron').delete
    #   people.where(cn: 'Optimus').delete
    # end

    it 'returns a single tuple' do
      expect(people.fetch('cn=Megatron,ou=specs,dc=example,dc=com')[:uid_number]).to eql(1)
      expect(people.fetch('cn=Optimus,ou=specs,dc=example,dc=com')[:create_timestamp].class).to eql(Time)
    end

    it 'raises when tuple was not found' do
      expect {
        people.fetch('uid=unknown,ou=spec,dc=example,dc=com')
      }.to raise_error(ROM::TupleCountMismatchError, 'The relation does not contain any tuples')
    end

    it 'raises when more tuples are found' do
      expect {
        people.fetch([
          'cn=Megatron,ou=specs,dc=example,dc=com',
          'cn=Optimus,ou=specs,dc=example,dc=com'
        ])
      }.to raise_error(ROM::TupleCountMismatchError, 'The relation consists of more than one tuple')
    end
  end


  context 'with custom primary_key' do
    before do
      conf.relation(:foo) do
        schema('(objectClass=inetOrgPerson)', infer: true) do
          attribute 'uidNumber', ROM::LDAP::Types::Integer.meta(primary_key: true)
        end
      end
    end

    include_context 'people'

    before do
      factories[:person, cn: 'Megatron', uid_number: 1]
      factories[:person, cn: 'Optimus', uid_number: 2]
    end

    # after do
    #   people.where(cn: 'Megatron').delete
    #   people.where(cn: 'Optimus').delete
    # end

    it 'returns a single tuple' do
      expect(relations.foo.fetch(1)[:uid_number]).to eql(1)
    end

    it 'raises when tuple was not found' do
      expect {
        relations.foo.fetch(5_315_412)
      }.to raise_error(ROM::TupleCountMismatchError, 'The relation does not contain any tuples')
    end

    it 'raises when more tuples are found' do
      expect {
        relations.foo.fetch([1, 2])
      }.to raise_error(ROM::TupleCountMismatchError, 'The relation consists of more than one tuple')
    end
  end

end
