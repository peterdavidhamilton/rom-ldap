require 'spec_helper'

RSpec.describe ROM::LDAP::Relation do
  include_context 'factories'

  # [
  #   { uid: 'huey', uniqueidentifier: 1 },
  #   { uid: 'dewey', uniqueidentifier: 4 },
  #   { uid: 'louie', uniqueidentifier: 9 },
  #   { uid: 'donald', uniqueidentifier: 16 }
  # ]
  #
  let(:user_names) { %w[huey dewey louie donald] }

  describe '#gte uniqueidentifier >= 5' do
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
                [:op_eq, 'objectclass', 'person'],
                [:op_eq, 'gidnumber', '1']
              ]
            ],
            # criteria
            [:op_gte, :uniqueidentifier, 5]
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
          { uid: 'louie', uniqueidentifier: 9 },
          { uid: 'donald', uniqueidentifier: 16 }
        ]
      )
    end
  end



  describe '#gt uniqueidentifier > 9' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].gt(uniqueidentifier: 9) }

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
              [:op_lte, :uniqueidentifier, 9]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectclass=person)(gidnumber=1))(!(uniqueidentifier<=9)))'
      )
    end

    it 'result' do
      results = relation.with(auto_struct: false).select(:uid, :uniqueidentifier).to_a
      expect(results).to eql(
        [
          { uid: 'donald', uniqueidentifier: 16 }
        ]
      )
    end
  end



  describe '#lte uniqueidentifier <= 9' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].lte(uniqueidentifier: 9) }

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
            [:op_lte, :uniqueidentifier, 9]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectclass=person)(gidnumber=1))(uniqueidentifier<=9))'
      )
    end

    it 'result' do
      results = relation.with(auto_struct: false).select(:uid, :uniqueidentifier).to_a
      expect(results).to eql(
        [
          { uid: 'huey', uniqueidentifier: 1 },
          { uid: 'dewey', uniqueidentifier: 4 },
          { uid: 'louie', uniqueidentifier: 9 },
        ]
      )
    end
  end



  describe '#lt uniqueidentifier < 4' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].lt(uniqueidentifier: 4) }

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
              [:op_gte, :uniqueidentifier, 4]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql(
        '(&(&(objectclass=person)(gidnumber=1))(!(uniqueidentifier>=4)))'
      )
    end

    it 'result' do
      results = relation.with(auto_struct: false).select(:uid, :uniqueidentifier).to_a
      expect(results).to eql(
        [
          { uid: 'huey', uniqueidentifier: 1 }
        ]
      )
    end
  end

end
