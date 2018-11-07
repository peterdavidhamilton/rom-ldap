require 'rom-factory'

RSpec.shared_context 'factory' do

  include_context 'directory'

  let(:factories) do
    ROM::Factory.configure { |conf| conf.rom = container }
  end

  before do
    # @note
    #   Select LDAP attribute formatter before defining relations.
    #
    ROM::LDAP.load_extensions :compatibility

    directory.add(
      dn: 'ou=specs,dc=example,dc=com',
      ou: 'specs',
      object_class: %w'organizationalUnit top'
    )
  end


  after do
    directory.delete('ou=specs,dc=example,dc=com')
  end

end
