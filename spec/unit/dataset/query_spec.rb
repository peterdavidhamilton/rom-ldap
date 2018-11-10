# con_and:  '&'      # AND
# con_or:   '|'      # OR
# con_not:  '!'      # NOT
# op_prx:   '~='     # Approximately equal to
# op_ext:   ':='     # Bitwise comparison of numeric values
# op_gte:   '>='     # Lexicographically greater than or equal to
# op_lte:   '<='     # Lexicographically less than or equal to
# op_eql:   '='      # Equal to
# op_bineq: '='      #   uses #to_ber_bin on value

# In addition to the operators above,
# LDAP defines two matching rule object identifiers (OIDs) that can be used to
# perform bitwise comparisons of numeric values.
# Matching rules have the following syntax.


RSpec.describe ROM::LDAP::Dataset, 'QueryDSL' do

  include_context 'animals'

  subject(:dataset) { animals.dataset }

  describe 'exact matches' do
    it '#equal' do
      expect(dataset.equal(bar: 'foo').opts[:criteria]).to eql([:op_eql, :bar, 'foo'])
    end

    it '#where (equal)' do
      expect(dataset.where(bar: 'foo').opts[:criteria]).to eql([:op_eql, :bar, 'foo'])
    end

    it '#unequal' do
      expect(dataset.unequal(bar: 'foo').opts[:criteria]).to eql([:con_not, [:op_eql, :bar, 'foo']])
    end

    it '#where_not (unequal)' do
      expect(dataset.where_not(bar: 'foo').opts[:criteria]).to eql([:con_not, [:op_eql, :bar, 'foo']])
    end
  end

  describe 'wildcard values' do
    it '#present' do
      expect(dataset.present(:bar).opts[:criteria]).to eql(%i[op_eql bar wildcard])
    end

    it '#has (present)' do
      expect(dataset.has(:bar).opts[:criteria]).to eql(%i[op_eql bar wildcard])
    end

    it '#missing' do
      expect(dataset.missing(:bar).opts[:criteria]).to eql([:con_not, %i[op_eql bar wildcard]])
    end

    it '#hasnt (missing)' do
      expect(dataset.hasnt(:bar).opts[:criteria]).to eql([:con_not, %i[op_eql bar wildcard]])
    end
  end

  describe 'size comparisons' do
    it '#gt' do
      expect(dataset.gt(bar: 'foo').opts[:criteria]).to eql([:con_not, [:op_lte, :bar, 'foo']])
    end

    it '#above (gt)' do
      expect(dataset.above(bar: 100).opts[:criteria]).to eql([:con_not, [:op_lte, :bar, 100]])
    end

    it '#lt' do
      expect(dataset.lt(bar: 100).opts[:criteria]).to eql([:con_not, [:op_gte, :bar, 100]])
    end

    it '#below (lt)' do
      expect(dataset.below(bar: 'baz').opts[:criteria]).to eql([:con_not, [:op_gte, :bar, 'baz']])
    end

    it '#lte' do
      expect(dataset.lte(bar: 100).opts[:criteria]).to eql([:op_lte, :bar, 100])
    end

    it '#gte' do
      expect(dataset.gte(bar: 100).opts[:criteria]).to eql([:op_gte, :bar, 100])
    end
  end

  describe 'fuzzy searches' do
    it '#begins' do
      expect(dataset.begins(bar: 'foo').opts[:criteria]).to eql([:op_eql, :bar, 'foo*'])
    end

    it '#ends' do
      expect(dataset.ends(bar: 'foo').opts[:criteria]).to eql([:op_eql, :bar, '*foo'])
    end

    it '#contains' do
      expect(dataset.contains(bar: 'foo').opts[:criteria]).to eql([:op_eql, :bar, '*foo*'])
    end

    it '#matches (contains)' do
      expect(dataset.matches(bar: 'foo').opts[:criteria]).to eql([:op_eql, :bar, '*foo*'])
    end

    it '#excludes' do
      expect(dataset.excludes(bar: 'foo').opts[:criteria]).to eql([:con_not, [:op_eql, :bar, '*foo*']])
    end
  end

  describe 'ranged searches' do
    it '#within' do
      expect(dataset.within(bar: 0..10).opts[:criteria]).to eql(
        [:con_and, [[:op_gte, :bar, 0], [:op_lte, :bar, 10]]]
      )
    end

    it '#between (within)' do
      expect(dataset.between(bar: 'A'..'Z').opts[:criteria]).to eql(
        [:con_and, [[:op_gte, :bar, 'A'], [:op_lte, :bar, 'Z']]]
      )
    end

    it '#outside' do
      expect(dataset.outside(bar: 1..999).opts[:criteria]).to eql(
        [:con_not, [:con_and, [[:op_gte, :bar, 1], [:op_lte, :bar, 999]]]]
      )
    end
  end



  describe 'FOO!' do

    it 'op_bineq' do
      expect(dataset.binary_equal(bar: 'foo').opts[:criteria]).to eql(
        [:op_bineq, :bar, 'foo']
      )
    end

    it 'op_ext' do
      expect(dataset.bitwise(bar: 'foo').opts[:criteria]).to eql([:op_ext, :bar, 'foo'])
    end

    it 'op_prx' do
      expect(dataset.approx(bar: 'foo').opts[:criteria]).to eql([:op_prx, :bar, 'foo'])
    end
  end



  describe 'chained criteria' do

    it '2 methods' do
      expect(dataset.where(bar: %w'foo baz').above(quux: 100).opts[:criteria]).to eql(
        [
          :con_and,
          [
            [
              :con_or,
              [
                [:op_eql, :bar, 'foo'],
                [:op_eql, :bar, 'baz']
              ]
            ],
            [
              :con_not,
              [:op_lte, :quux, 100]
            ]
          ]
        ]
      )
    end

  end
end
