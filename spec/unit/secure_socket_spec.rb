using ::BER

RSpec.describe ROM::LDAP::SecureSocket do

  let(:socket) { ::Socket.new(:INET, :STREAM) }

  let(:cert) { ENV['HOME'] + '/.minikube/client.crt' }

  let(:key) { ENV['HOME'] + '/.minikube/client.key' }

  let(:ca) { ENV['HOME'] + '/.minikube/ca.crt' }

  let(:wrapper) { described_class.new(socket, cert: cert, key: key, ca: ca) }

  let(:ssl) { wrapper.call }

# openldap
  let(:gateway) do
    TestConfiguration.new(:ldap,
      'ldaps://rancher:2636',
      username: 'cn=admin,dc=rom,dc=ldap',
      password: 'topsecret',
      ssl: { cert: cert, key: key, ca: ca }
    ).gateways[:default]
  end




  # it '#type' do
  #   expect(gateway.directory.type).to eql(:open_ldap)
  # end

  xit 'does something' do
    binding.pry
  end

end
