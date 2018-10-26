RSpec.describe ROM::LDAP::Relation, helpers: true do

  let(:formatter) { nil }
  include_context 'directory'

  after(:each) do
    reset_attributes!
  end

  #
  # Default Primary Key = DN
  #
  describe '#fetch default primary_key' do
    before do
      use_formatter(formatter)

      conf.relation(:foo) do
        schema(users, infer: true)
      end
    end

    let(:relation) { relations.foo }

    # @todo inferred types are wrong?
    it 'returns a single tuple identified by the pk' do
      expect(relation.fetch('uid=test1,ou=users,dc=example,dc=com')['uidNumber']).to eql(1)
      # expect(relation.fetch('uid=test1,ou=users,dc=example,dc=com')['createTimestamp'].class).to eql(Time)
    end

    it 'raises when tuple was not found' do
      expect {
        relation.fetch('uid=unknown,ou=users,dc=example,dc=com')
      }.to raise_error(ROM::TupleCountMismatchError, 'The relation does not contain any tuples')
    end

    it 'raises when more tuples were returned' do
      expect {
        relation.fetch([
          'uid=test1,ou=users,dc=example,dc=com',
          'uid=test2,ou=users,dc=example,dc=com'
        ])
      }.to raise_error(ROM::TupleCountMismatchError, 'The relation consists of more than one tuple')
    end
  end

  #
  # Custom Primary Key = uidNumber
  #
  describe '#fetch custom primary_key' do
    before do
      use_formatter(formatter)

      conf.relation(:foo) do
        schema(users, infer: true) do
          attribute 'uidNumber', ROM::LDAP::Types::Integer.meta(primary_key: true)
        end
      end
    end

    let(:relation) { relations.foo }

    it 'returns a single tuple identified by the pk' do
      expect(relation.fetch(1)['uidNumber']).to eql(1)
    end

    it 'raises when tuple was not found' do
      expect {
        relation.fetch(5_315_412)
      }.to raise_error(ROM::TupleCountMismatchError, 'The relation does not contain any tuples')
    end

    it 'raises when more tuples were returned' do
      expect {
        relation.fetch([1, 2])
      }.to raise_error(ROM::TupleCountMismatchError, 'The relation consists of more than one tuple')
    end
  end

end
