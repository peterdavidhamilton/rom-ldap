require 'spec_helper'

RSpec.describe 'there be dragons' do

  include_context 'dragons'

  before do
    factories[:animals,
              dn: 'cn=Falkor,ou=animals,dc=example,dc=com',
              cn: ["Falkor", "Luck Dragon"],
              species: 'dragon',
              objectclass: 'reptilia'
    ]
  end

  it 'works' do
    expect(dragons.count).to eql(1)
    expect(dragons.first[:species]).to eql('dragon')
  end

end
