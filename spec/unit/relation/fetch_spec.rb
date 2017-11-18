require 'spec_helper'

RSpec.describe ROM::LDAP::Relation, helpers: true do

  describe '#fetch' do
    include_context 'directory'

    let(:formatter) { nil }

    before do
      use_formatter(formatter)

      conf.relation(:foo) do
        schema(users, infer: true) do
          attribute 'uidNumber', ROM::LDAP::Types::Serial
          primary_key 'uidNumber'
        end
      end
    end

    let(:relation) { relations.foo }

    it 'returns a single tuple identified by the pk' do
      expect(relation.fetch(1)['uidNumber']).to eql(['1'])
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
