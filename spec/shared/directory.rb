RSpec.shared_context 'directory' do

  let(:server) do
    { server: '127.0.0.1:10389', username: nil, password: nil }
  end

  let(:ldap_options) do
    { base: 'ou=users,dc=example,dc=com' }
  end

  let(:conf) do
    ROM::Configuration.new(:ldap, server, ldap_options)
  end

  let(:container) do
    ROM.container(conf)
  end

  let(:conn) do
    conf.gateways[:default].connection
  end

  let(:relations) do
    container.relations
  end

  let(:reverse_proc) do
    ->(key) { key.to_s.downcase.tr('-= ', '').reverse.to_sym }
  end

  let(:downcase_proc) do
    ->(key) { key.to_s.downcase.tr('-= ', '').to_sym }
  end

  let(:method_name_proc) do
    ->(key) { ROM::LDAP::Functions.to_method_name(key) }
  end

end
