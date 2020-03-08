RSpec.xdescribe ROM::LDAP::Relation, 'paged results' do

  include_context 'vendor', 'apache_ds'

  it do
    # calls client.search
    foo = directory.query(base: '', paged: true)
  end

end
