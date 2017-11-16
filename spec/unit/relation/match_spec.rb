require 'spec_helper'

RSpec.describe ROM::LDAP::Relation do
  include_context 'factories'

  let(:user_names) { %w[rita sue bob] }

  describe '#present' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].present('uidNumber') }

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
            [:op_equal, 'uidNumber', :wildcard]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql('(&(&(objectclass=person)(gidnumber=1))(uidNumber=*))')
    end

    it 'result count' do
      expect(relation.count).to eql(3)
    end
  end

  describe '#missing' do
    let(:relation) { relations[:people].missing(:mail) }

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
              :con_not,
              [:op_equal, :mail, :wildcard]
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql('(&(&(objectclass=person)(gidnumber=1))(!(mail=*)))')
    end

    it 'result count' do
      expect(relation.count).to eql(0)
    end
  end


  describe '#begins' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].begins(uid: 'b') }

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
            [:op_equal, :uid, 'b*']
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql('(&(&(objectclass=person)(gidnumber=1))(uid=b*))')
    end

    it 'result' do
      expect(relation.one.uid).to eql('bob')
    end
  end


  describe '#ends' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].ends(uid: 'a') }

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
            [:op_equal, :uid, '*a']
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql('(&(&(objectclass=person)(gidnumber=1))(uid=*a))')
    end

    it 'result' do
      expect(relation.one.uid).to eql('rita')
    end
  end


  describe '#contains' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].contains(uid: 'o') }

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
            [:op_equal, :uid, '*o*']
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql('(&(&(objectclass=person)(gidnumber=1))(uid=*o*))')
    end

    it 'result' do
      expect(relation.one.uid).to eql('bob')
    end
  end


  describe '#excludes' do
    let(:formatter) { old_format_proc }
    let(:relation) { relations[:people].excludes(uid: 'i') }

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
              :con_not,
              [:op_equal, :uid, '*i*']
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.filter).to eql('(&(&(objectclass=person)(gidnumber=1))(!(uid=*i*)))')
    end

    it 'result count' do
      expect(relation.count).to eql(2)
    end
  end

end
