require 'spec_helper'

RSpec.describe ROM::LDAP::Relation do
  include_context 'factories'

  let(:user_names) { %w[barry billy bobby sally] }

  describe '#equals with single value' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].equals(uid: 'billy') }

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
                [:op_eq, 'objectclass', 'person'],
                [:op_eq, 'gidnumber', '1']
              ]
            ],
            # criteria
            [:op_eq, :uid, 'billy']
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql('(&(&(objectclass=person)(gidnumber=1))(uid=billy))')
    end

    it 'result count' do
      expect(relation.count).to eql(1)
    end
  end

  describe '#where (alias) with multiple values' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].where(uid: %w[billy sally]) }

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
                [:op_eq, 'objectclass', 'person'],
                [:op_eq, 'gidnumber', '1']
              ]
            ],
            # criteria
            [
              :con_or,
              [
                [:op_eq, :uid, 'billy'],
                [:op_eq, :uid, 'sally']
              ]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql('(&(&(objectclass=person)(gidnumber=1))(|(uid=billy)(uid=sally)))')
    end

    it 'result count' do
      expect(relation.count).to eql(2)
    end
  end



  describe '#unequals with single value' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].unequals(uid: 'sally') }

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
                [:op_eq, 'objectclass', 'person'],
                [:op_eq, 'gidnumber', '1']
              ]
            ],
            # criteria
            [
              :con_not,
              [:op_eq, :uid, 'sally']
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql('(&(&(objectclass=person)(gidnumber=1))(!(uid=sally)))')
    end

    it 'result count' do
      expect(relation.count).to eql(3)
    end
  end



  describe '#unequals with multiple values' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].unequals(uid: %w[billy sally]) }

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
                [:op_eq, 'objectclass', 'person'],
                [:op_eq, 'gidnumber', '1']
              ]
            ],
            # criteria
            [
              :con_not,
              [
                :con_or,
                [
                  [:op_eq, :uid, 'billy'],
                  [:op_eq, :uid, 'sally']
                ]
              ]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql('(&(&(objectclass=person)(gidnumber=1))(!(|(uid=billy)(uid=sally))))')
    end

    it 'result count' do
      expect(relation.count).to eql(2)
    end
  end

end
