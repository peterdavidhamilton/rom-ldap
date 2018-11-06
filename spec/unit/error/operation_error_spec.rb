RSpec.describe ROM::LDAP::OperationError do

  include_context 'animals'

  it 'every operation needs a dn' do
    expect {
      factories[:animal, dn: nil]
    }.to raise_error(ROM::LDAP::OperationError, 'distinguished name is required')
  end

end
