RSpec.describe ROM::LDAP::Relation do

  let(:formatter) { downcase_formatter }

  include_context 'factory'

  let(:user_names) { %w[rita sue bob] }


  describe '#begins' do
    let(:relation) { relations[:people].begins(uid: 'b') }

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
            [:op_eql, :uid, 'b*']
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.ldap_string).to eql('(&(&(objectClass=person)(gidNumber=1))(uid=b*))')
    end

    it 'result' do
      expect(relation.one.mail).to eql('bob@example.com')
    end
  end


  describe '#ends' do
    let(:relation) { relations[:people].ends(uid: 'a') }

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
            [:op_eql, :uid, '*a']
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.ldap_string).to eql('(&(&(objectClass=person)(gidNumber=1))(uid=*a))')
    end

    it 'result' do
      expect(relation.one.mail).to eql('rita@example.com')
    end
  end


  describe '#contains' do
    let(:relation) { relations[:people].contains(uid: 'o') }

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
            [:op_eql, :uid, '*o*']
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.ldap_string).to eql('(&(&(objectClass=person)(gidNumber=1))(uid=*o*))')
    end

    it 'result' do
      expect(relation.one.mail).to eql('bob@example.com')
    end
  end


  describe '#excludes' do
    let(:relation) { relations[:people].excludes(uid: 'i') }

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
              [:op_eql, :uid, '*i*']
            ]
          ]
        ]
      )
    end

    it 'combined filter' do
      expect(relation.ldap_string).to eql('(&(&(objectClass=person)(gidNumber=1))(!(uid=*i*)))')
    end

    it 'result count' do
      expect(relation.count).to eql(2)
    end
  end

end
