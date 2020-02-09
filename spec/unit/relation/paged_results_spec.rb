RSpec.xdescribe ROM::LDAP::Relation, 'paged results' do

  include_context 'vendor', 'apache_ds'

  it 'does something' do
    directory.pageable?

    # calls client.search
    #
    foo = directory.query(base: '', paged: true)

    binding.pry
  end

end
