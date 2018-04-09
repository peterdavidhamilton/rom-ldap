RSpec.shared_context 'directory' do

  let(:server) do
    {
      username: nil,
      password: nil,
      uri:      '127.0.0.1:10389',
      base:     'ou=users,dc=example,dc=com',
      logger:   Logger.new(File.open('./log/test.log', 'a'))
    }
  end

  let(:conf) do
    ROM::Configuration.new(:ldap, server)
  end

  let(:container) do
    ROM.container(conf)
  end

  let(:connection) do
    conf.gateways[:default].connection
  end

  let(:directory) do
    conf.gateways[:default].directory
  end

  let(:relations) do
    container.relations
  end

  let(:commands) do
    container.commands
  end

  #
  # Example functions to format attributes.
  #

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
