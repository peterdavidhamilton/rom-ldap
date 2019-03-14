RSpec.describe ROM::LDAP::Directory::Entry do

  include_context 'directory'

  subject(:entry) { directory.query.first }

  it 'eql?' do
    expect(directory.query.first).to eql(entry)
  end

end