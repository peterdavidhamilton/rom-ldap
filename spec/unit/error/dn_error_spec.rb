RSpec.describe ROM::LDAP::DistinguishedNameError do

  include_context 'animals'

  it 'every operation needs a dn' do
    expect {
      factories[:animal, dn: nil]
    }.to raise_error(ROM::LDAP::DistinguishedNameError, 'DN is required')
  end

end
