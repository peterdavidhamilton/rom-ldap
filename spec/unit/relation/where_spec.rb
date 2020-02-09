RSpec.describe ROM::LDAP::Relation, '#where' do

  include_context 'entries'

  before do
    factories[:entry, cn: 'foo']
    factories[:entry, cn: 'bar']
    factories[:entry, cn: 'baz']
  end

  with_vendors do

    describe 'with arguments' do
      context 'AND' do
        it 'requires all chained criteria to be met' do
          expect(entries.where(cn: %w{foo bar baz}).where(cn: 'baz').count).to eql(1)
          expect(entries.where(cn: %w{foo bar}).where(cn: 'baz').count).to eql(0)
        end
      end

      context 'OR' do
        it 'accepts multiple values for an attribute' do
          expect(entries.where(cn: %w{foo}).count).to eql(1)
          expect(entries.where(cn: %w{foo bar}).count).to eql(2)
          expect(entries.where(cn: %w{foo bar baz}).count).to eql(3)
        end

        it 'requires either criteria to be met' do
          expect(entries.where(cn: 'foo', object_class: 'foo').count).to eql(1)
          expect(entries.where(cn: 'foo', object_class: 'top').count).to eql(3)
        end
      end
    end

  end
end
