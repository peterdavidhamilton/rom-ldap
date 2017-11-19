require 'spec_helper'

RSpec.describe ROM::LDAP::Relation do
  include_context 'factories'

  let(:user_names) { %w[barry billy bobby sally] }

  describe '#equals with single value' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].equals(uid: 'billy') }

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
            [:op_eql, :uid, 'billy']
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql('(&(&(objectClass=person)(gidNumber=1))(uid=billy))')
    end

    it 'result count' do
      expect(relation.count).to eql(1)
    end
  end

 describe '#equals with multiple attributes' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].equals(uid: 'billy', mail: 'billy@example.com') }

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
                [:op_eql, :uid, 'billy'],
                [:op_eql, :mail, 'billy@example.com']
              ]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectClass=person)(gidNumber=1))(&(uid=billy)(mail=billy@example.com)))'
      )
    end

    it 'result count' do
      expect(relation.count).to eql(1)
    end
  end

  describe '#where (alias) with multiple values' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].where(uid: %w[billy sally]) }

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
              :con_or,
              [
                [:op_eql, :uid, 'billy'],
                [:op_eql, :uid, 'sally']
              ]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectClass=person)(gidNumber=1))(|(uid=billy)(uid=sally)))'
      )
    end

    it 'result count' do
      expect(relation.count).to eql(2)
    end
  end



  describe '#unequals with single value' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].unequals(uid: 'sally') }

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
              :con_not,
              [:op_eql, :uid, 'sally']
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectClass=person)(gidNumber=1))(!(uid=sally)))'
      )
    end

    it 'result count' do
      expect(relation.count).to eql(3)
    end
  end



  describe '#unequals with multiple values' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].unequals(uid: %w[billy sally]) }

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
              :con_not,
              [
                :con_or,
                [
                  [:op_eql, :uid, 'billy'],
                  [:op_eql, :uid, 'sally']
                ]
              ]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectClass=person)(gidNumber=1))(!(|(uid=billy)(uid=sally))))'
      )
    end

    it 'result count' do
      expect(relation.count).to eql(2)
    end
  end

end
