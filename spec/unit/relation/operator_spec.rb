RSpec.describe ROM::LDAP::Relation, 'special operators' do

  include_context 'animals'

  before do
    factories[:animal]
  end

  # https://docs.microsoft.com/en-us/windows/desktop/ADSI/search-filter-syntax
  xit '#bitwise' do
    expect(animals.bitwise('groupType:1.2.840.113556.1.4.803' => 2147483648).to_a).to eql([])
    # expect(animals.bitwise('userAccountControl:1.2.840.113556.1.4.803' => 2).to_a).to eql([])
  end

  # https://ldapwiki.com/wiki/ApproxMatch
  # https://en.wikipedia.org/wiki/Soundex
  #
  # Search for homophones
  #
  xit 'is approx' do
    expect(animals.with_base('ou=animals,dc=rom,dc=ldap').approx(cn: 'cam').to_a).to eql([])
  end

end
