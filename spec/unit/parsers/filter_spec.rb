RSpec.describe ROM::LDAP::Parsers::Filter do

  describe 'valid string format' do

    it 'permitted' do
      expect {
        ROM::LDAP::Parsers::Filter.new('(givenName=Peter)', schemas: [])
      }.to_not raise_error
    end
  end

  describe 'invalid params' do

    it 'caught by type constraint' do
      expect {
        ROM::LDAP::Parsers::Filter.new('[givenName=Peter]', schemas: [])
      }.to raise_error(Dry::Types::ConstraintError)
    end
  end

end
