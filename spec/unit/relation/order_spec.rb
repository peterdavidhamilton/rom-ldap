require 'spec_helper'

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

  describe 'DSL' do

    # First set proc
    let(:formatter) { method_name_proc }
    # Second load before blocks to generate entries
    include_context 'factories'
    # Third overload names to generate
    let(:user_names) { %w[huey dewey louie donald] }

    describe '#gte uidnumber >= 5' do
      let(:relation) { relations[:people].gte(uidnumber: 5) }

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
              [:op_gte, :uidnumber, 5]
            ]
          ]
        )
      end

      it 'combined filter' do
        expect(relation.filter).to eql(
          '(&(&(objectClass=person)(gidNumber=1))(uidNumber>=5))'
        )
      end

      it 'result' do
        results = relation.with(auto_struct: false).select(:uid, :uidnumber).to_a
        expect(results).to eql(
          [
            { uid: 'donald', uidnumber: 16 },
            { uid: 'louie', uidnumber: 9 }
          ]
        )
      end
    end


    describe '#gt uidnumber > 9' do
      let(:relation) { relations[:people].gt(uidnumber: 9) }

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
                [:op_lte, :uidnumber, 9]
              ]
            ]
          ]
        )
      end

      it 'combined filter' do
        expect(relation.filter).to eql(
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
      let(:relation) { relations[:people].lte(uidnumber: 9) }

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
              [:op_lte, :uidnumber, 9]
            ]
          ]
        )
      end

      it 'combined filter' do
        expect(relation.filter).to eql(
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
      let(:relation) { relations[:people].lt(uidnumber: 4) }

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
                [:op_gte, :uidnumber, 4]
              ]
            ]
          ]
        )
      end

      it 'combined filter' do
        expect(relation.filter).to eql(
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
end
