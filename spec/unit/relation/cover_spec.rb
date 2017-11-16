require 'spec_helper'

RSpec.describe ROM::LDAP::Relation do
  include_context 'factories'

  # [
  #   { uid: 'zippy', uniqueidentifier: 1 },
  #   { uid: 'george', uniqueidentifier: 4 },
  #   { uid: 'bungle', uniqueidentifier: 9 },
  #   { uid: 'geoffrey', uniqueidentifier: 16 }
  # ]
  #
  let(:user_names) { %w[zippy george bungle geoffrey] }

  describe '#within' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].within(uniqueidentifier: 3..9) }

    it 'source filter' do
      expect(relation.source).to eql('(&(objectclass=person)(gidnumber=1))')
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
                [:op_equal, 'objectclass', 'person'],
                [:op_equal, 'gidnumber', '1']
              ]
            ],
            # criteria
            [
              :con_and,
              [
                [:op_gt_eq, :uniqueidentifier, 3],
                [:op_lt_eq, :uniqueidentifier, 9]
              ]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectclass=person)(gidnumber=1))(&(uniqueidentifier>=3)(uniqueidentifier<=9)))'
      )
    end

    it 'result count' do
      expect(relation.count).to eql(2)
    end
  end


  describe '#between' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].between(uniqueidentifier: -1..12) }

    it 'source filter' do
      expect(relation.source).to eql('(&(objectclass=person)(gidnumber=1))')
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
                [:op_equal, 'objectclass', 'person'],
                [:op_equal, 'gidnumber', '1']
              ]
            ],
            # criteria
            [
              :con_and,
              [
                [:op_gt_eq, :uniqueidentifier, -1],
                [:op_lt_eq, :uniqueidentifier, 12]
              ]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectclass=person)(gidnumber=1))(&(uniqueidentifier>=-1)(uniqueidentifier<=12)))'
      )
    end

    it 'result count' do
      expect(relation.count).to eql(3)
    end
  end


  # TODO: finish these
  # it '#outside' do
  #   results = relation.outside(uniqueidentifier: 30..100)

  #   expect(results.to_a.count).to eql(4)
  #   expect(results.select(:uniqueidentifier).to_a.map(&:values)).to cover(4)
  # end


  describe '#gte' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].gte(uniqueidentifier: 5) }

    it 'source filter' do
      expect(relation.source).to eql('(&(objectclass=person)(gidnumber=1))')
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
                [:op_equal, 'objectclass', 'person'],
                [:op_equal, 'gidnumber', '1']
              ]
            ],
            # criteria
            [:op_gt_eq, :uniqueidentifier, 5]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectclass=person)(gidnumber=1))(uniqueidentifier>=5))'
      )
    end

    it 'result' do
      results = relation.with(auto_struct: false).select(:uid, :uniqueidentifier).to_a
      expect(results).to eql(
        [
          { uid: 'bungle', uniqueidentifier: 9 },
          { uid: 'geoffrey', uniqueidentifier: 16 }
        ]
      )
    end
  end


  # it '#gte' do
  #   expect(relation.gte(uniqueidentifier: 4).count).to eql(3)
  #   expect(relation.above(uniqueidentifier: 5).count).to eql(2)
  # end

  # it '#lte' do
  #   expect(relation.lte(uniqueidentifier: 9).count).to eql(3)
  #   expect(relation.below(uniqueidentifier: 11).count).to eql(3)
  # end
end
