# FIXME: this test snject is ambiguous ( >, <, >=, <=, etc)
# Order DSL methods for numeric values ordered by size.
#
# [
#   { uid: 'dewey',   uidnumber: 4  },
#   { uid: 'donald',  uidnumber: 16 },
#   { uid: 'huey',    uidnumber: 1  },
#   { uid: 'louie',   uidnumber: 9  }
# ]
#
RSpec.describe ROM::LDAP::Relation do

  let(:formatter) { downcase_proc }

  before do
    conf.relation(:foo) do
      schema('(&(objectClass=person)(gidNumber=1))', infer: true) do
        attribute :uid, ROM::LDAP::Types::Strings,
          read: ROM::LDAP::Types::String

        attribute :uidnumber, ROM::LDAP::Types::Integers,
          read: ROM::LDAP::Types::Integer
      end
    end
  end

  include_context 'factories'

  let(:user_names) { %w[huey dewey louie donald] }

  describe '#gte uidnumber >= 5' do
    let(:relation) { relations[:foo].gte(uidnumber: 5) }

    it 'source filter' do
      expect(relation.source_filter).to eql('(&(objectClass=person)(gidNumber=1))')
    end

    it 'chained criteria' do
      expect(relation.query_ast).to eql(
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
            [:op_gte, :uidnumber, 5]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.ldap_string).to eql(
        '(&(&(objectClass=person)(gidNumber=1))(uidNumber>=5))'
      )
    end

    it 'result' do
      results = relation.select(:uid, :uidnumber).to_a
      expect(results).to eql(
        [
          { uid: 'donald', uidnumber: 16 },
          { uid: 'louie', uidnumber: 9 }
        ]
      )
    end
  end


  describe '#gt uidnumber > 9' do
    let(:relation) { relations[:foo].gt(uidnumber: 9) }

    it 'source filter' do
      expect(relation.source_filter).to eql('(&(objectClass=person)(gidNumber=1))')
    end

    it 'chained criteria' do
      expect(relation.query_ast).to eql(
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
              [:op_lte, :uidnumber, 9]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.ldap_string).to eql(
        '(&(&(objectClass=person)(gidNumber=1))(!(uidNumber<=9)))'
      )
    end

    it 'result' do
      results = relation.with(auto_struct: false).select(:uid, :uidnumber).to_a
      expect(results).to eql(
        [
          { uid: 'donald', uidnumber: 16 }
        ]
      )
    end
  end



  describe '#lte uidnumber <= 9' do
    let(:relation) { relations[:foo].lte(uidnumber: 9) }

    it 'source filter' do
      expect(relation.source_filter).to eql('(&(objectClass=person)(gidNumber=1))')
    end

    it 'chained criteria' do
      expect(relation.query_ast).to eql(
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
            [:op_lte, :uidnumber, 9]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.ldap_string).to eql(
        '(&(&(objectClass=person)(gidNumber=1))(uidNumber<=9))'
      )
    end

    it 'result' do
      results = relation.with(auto_struct: false).select(:uid, :uidnumber).to_a
      expect(results).to eql(
        [
          { uid: 'dewey', uidnumber: 4 },
          { uid: 'huey', uidnumber: 1 },
          { uid: 'louie', uidnumber: 9 }
        ]
      )
    end
  end



  describe '#lt uidnumber < 4' do
    let(:relation) { relations[:foo].lt(uidnumber: 4) }

    it 'source filter' do
      expect(relation.source_filter).to eql('(&(objectClass=person)(gidNumber=1))')
    end

    it 'chained criteria' do
      expect(relation.query_ast).to eql(
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
              [:op_gte, :uidnumber, 4]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.ldap_string).to eql(
        '(&(&(objectClass=person)(gidNumber=1))(!(uidNumber>=4)))'
      )
    end

    it 'result' do
      results = relation.with(auto_struct: false).select(:uid, :uidnumber).to_a
      expect(results).to eql(
        [
          { uid: 'huey', uidnumber: 1 }
        ]
      )
    end
  end

end
