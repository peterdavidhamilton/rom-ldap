RSpec.describe ROM::LDAP::Relation::Transaction do

  include_context 'associations'

  xit 'Work in progress' do
    species.transaction { 'foo' }
  end
end
