RSpec.describe ROM::LDAP::Relation, 'either' do

  include_context 'people'

  before do
    # %w[zippy george bungle geoffrey].each.with_index(1) do |gn, i|
    #   factories[:person, given_name: gn, uid_number: i**2]
    # end
  end

  xit 'builds and OR query' do
  end

end
