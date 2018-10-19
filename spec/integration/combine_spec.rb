RSpec.describe 'Combine relations' do

  include_context 'associations'

  before do
    # https://en.wikipedia.org/wiki/Indian_pangolin
    directory.add(
      dn: 'cn=Pangolin,ou=animals,dc=example,dc=com',
      # NB: extra common names only
      cn: %w[Indian\ Pangolin Thick-tailed\ Pangolin Scaly\ Anteater],
      species: 'Manis crassicaudata',
      objectclass: %w[extensibleObject mammalia]
    )

    countries << {
      name: 'India',
      dn: 'cn=Pangolin,ou=animals,dc=example,dc=com',
    }
  end

  it 'combine' do

    relations[:countries].to_a
    # [{:name=>"India", :dn=>"cn=Pangolin,ou=animals,dc=example,dc=com"}]

    countries.with_wildlife(predators.base).to_a
    prey.base.join(:countries).to_a

    # countries.with_wildlife([{dn: 'cn=Pangolin,ou=animals,dc=example,dc=com' }])
    # tags = container.relations[:tags]
    # relation = users.combine_with(tasks.for_users.combine_with(tags.for_tasks))

    # TODO: figure out a way to assert correct number of issued queries
    # expect(relation.call).to be_instance_of(ROM::Relation::Loaded)
  end

end
