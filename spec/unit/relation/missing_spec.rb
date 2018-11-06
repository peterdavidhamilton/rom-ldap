RSpec.describe ROM::LDAP::Relation, '#missing' do

  let(:formatter) { downcase_formatter }

  let(:user_names) { %w[rita sue bob] }
  include_context 'factory'

  subject(:relation) { relations[:people].missing(:mail) }

  it 'FILTER: (! (attr = *) )' do
    expect(relation.source_filter).to eql('(&(objectClass=person)(gidNumber=1))')
    expect(relation.ldap_string).to eql('(&(&(objectClass=person)(gidNumber=1))(!(mail=*)))')
  end

  it 'AST: [:con_not,[:op_eql, :attr, :wildcard]]' do
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
            [:op_eql, :mail, :wildcard]
          ]
        ]
      ]
    )
  end

  it 'returns tuples with no attribute' do
    expect(relation.first['mail']).to eql(nil)
  end
end
