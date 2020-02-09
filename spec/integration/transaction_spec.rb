RSpec.xdescribe ROM::LDAP::Relation::Transaction do

  include_context 'associations'

  it 'work in progress' do
    species.transaction { 'foo' }
  end
end
