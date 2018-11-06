RSpec.describe ROM::LDAP::Relation, '#present, #has, #exists' do

  let(:formatter) { downcase_formatter }

  include_context 'factory'

  let(:user_names) { %w[rita sue bob] }


  let(:relation) { relations[:people].present('uidNumber') }

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
          [:op_eql, 'uidNumber', :wildcard]
        ]
      ]
    )
  end

  it 'combined filter' do
    expect(relation.ldap_string).to eql('(&(&(objectClass=person)(gidNumber=1))(uidNumber=*))')
  end

  it 'result count' do
    expect(relation.count).to eql(3)
  end
end
