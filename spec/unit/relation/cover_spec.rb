require 'spec_helper'

RSpec.describe ROM::LDAP::Relation do
  include_context 'factories'

  # [
  #   { uid: 'bungle',   uidnumber: 9   },
  #   { uid: 'geoffrey', uidnumber: 16  },
  #   { uid: 'george',   uidnumber: 4   },
  #   { uid: 'zippy',    uidnumber: 1   }
  # ]
  #
  let(:user_names) { %w[zippy george bungle geoffrey] }

  describe '#within uidnumber 3..9' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].within(uidnumber: 3..9) }

    it 'source filter' do
      expect(relation.source).to eql('(&(objectClass=person)(gidNumber=1))')
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
                [:op_eql, 'gidNumber', '1']
              ]
            ],
            # criteria
            [
              :con_and,
              [
                [:op_gte, :uidnumber, 3],
                [:op_lte, :uidnumber, 9]
              ]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectClass=person)(gidNumber=1))(&(uidNumber>=3)(uidNumber<=9)))'
      )
    end

    it 'result' do
      expect(relation.count).to eql(2)
    end
  end


  describe '#between (alias) uidnumber -1..12' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].between(uidnumber: -1..12) }

    it 'source filter' do
      expect(relation.source).to eql('(&(objectClass=person)(gidNumber=1))')
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
                [:op_eql, 'gidNumber', '1']
              ]
            ],
            # criteria
            [
              :con_and,
              [
                [:op_gte, :uidnumber, -1],
                [:op_lte, :uidnumber, 12]
              ]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectClass=person)(gidNumber=1))(&(uidNumber>=-1)(uidNumber<=12)))'
      )
    end

    it 'result' do
      expect(relation.count).to eql(3)
    end
  end


  describe '#outside uidnumber 30..100' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].between(uidnumber: 30..100) }

    it 'source filter' do
      expect(relation.source).to eql('(&(objectClass=person)(gidNumber=1))')
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
                [:op_eql, 'gidNumber', '1']
              ]
            ],
            # criteria
            [
              :con_and,
              [
                [:op_gte, :uidnumber, 30],
                [:op_lte, :uidnumber, 100]
              ]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectClass=person)(gidNumber=1))(&(uidNumber>=30)(uidNumber<=100)))'
      )
    end

    it 'result' do
      # results = relation.with(auto_struct: false).select(:uidnumber).to_a
      # expect(results.map(&:values)).to cover(4)
      expect(relation.count).to eql(0)
    end
  end

end
