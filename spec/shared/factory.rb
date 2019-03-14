require 'rom-factory'

RSpec.shared_context 'factory' do

  include_context 'directory'

  before do
    directory.add(
      dn: 'ou=specs,dc=rom,dc=ldap',
      ou: 'specs',
      object_class: %w'organizationalUnit top'
    )
  end

  let(:factories) do
    ROM::Factory.configure { |conf| conf.rom = container }
  end

end
