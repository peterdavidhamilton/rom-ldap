RSpec.shared_context 'vendor' do |vendor|

  include_context 'directory'

  let(:vendor) { vendor }

  let(:uri) { uri_for(vendor) }

  before do
    if directory.find(base).empty?
      directory.add(
        dn: 'ou=specs,dc=rom,dc=ldap',
        ou: 'specs',
        objectClass: 'organizationalUnit'
      )
    end
  end

end
