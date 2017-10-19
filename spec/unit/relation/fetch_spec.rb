require 'spec_helper'

describe ROM::Relation, '#fetch' do
  include ContainerSetup

  let(:relation) { relations.accounts }

  describe '#fetch' do
    it 'returns a single tuple identified by the pk' do
      relation.fetch(1)[:uidnumber].must_equal(['1'])
    end

    it 'raises when tuple was not found' do
      proc { relation.fetch(535315412) }.must_raise(ROM::TupleCountMismatchError)
    end

    it 'raises when more tuples were returned' do
      proc { relation.fetch([1, 2]) }.must_raise(ROM::TupleCountMismatchError)
    end
  end

end
