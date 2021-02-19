RSpec.xdescribe ROM::LDAP::Relation, 'paged results' do

  with_vendors  do

    it do
      # calls client.search
      foo = directory.query(base: '', paged: true)
    end

  end

end
