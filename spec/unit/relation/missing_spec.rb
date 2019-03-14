RSpec.describe ROM::LDAP::Relation, '#missing' do

  include_context 'factory'

  let(:user_names) { %w[rita sue bob] }

  subject(:relation) { relations[:people].missing(:mail) }

end
