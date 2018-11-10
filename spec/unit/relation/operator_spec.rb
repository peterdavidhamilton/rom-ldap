RSpec.describe ROM::LDAP::Relation, 'special operators' do

  include_context 'animals'

  before do
    factories[:animal]
  end

  # https://docs.microsoft.com/en-us/windows/desktop/ADSI/search-filter-syntax
  xit '#bitwise' do
    # binding.pry
    # expect(animals.bitwise('groupType:1.2.840.113556.1.4.803' => 2147483648).to_a).to eql([])
    expect(animals.bitwise("groupType:#{MATCHING_RULE_BIT_AND}" => 2147483648).to_a).to eql([])
    # expect(animals.bitwise('groupType:1.2.840.113556.1.4.803' => 2147483648).to_a).to eql([])
    # expect(animals.bitwise('userAccountControl:1.2.840.113556.1.4.803' => 2).to_a).to eql([])
  end

                    # def binary_equal(args)
                    #   chain(:op_bineq, *args.to_a[0])
                    # end

  # https://ldapwiki.com/wiki/ApproxMatch
  # https://en.wikipedia.org/wiki/Soundex
  #
  # Search for homophones
  #
  it 'is approx' do
    binding.pry
    expect(animals.with_base('ou=animals,dc=rom,dc=ldap').approx(cn: 'cam').to_a).to eql([])
  end

end
