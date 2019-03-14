RSpec.describe ROM::LDAP::Relation, 'present' do

  include_context 'people'

  let(:user_names) { %w[rita sue bob] }

  before do
    %w[zippy george bungle geoffrey].each.with_index(1) do |gn, i|
      # factories[:person, given_name: gn, uid_number: i**2]
    end
  end

  subject(:relation) { people.present('uidNumber') }

end
