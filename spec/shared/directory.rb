RSpec.shared_context 'directory' do

  let(:base) do
    'ou=specs,dc=example,dc=com'
  end

  let(:servers) do
    # %w'127.0.0.1:389'
    [ "#{ENV['LDAPHOST']}:#{ENV['LDAPPORT']}" ]
  end

  let(:gateway_opts) do
    {
      servers: servers,
      base: base,
      # timeout: 0,
      logger: Logger.new(File.open('./log/test.log', 'a'))
    }
  end

  let(:conf) do
    ROM::Configuration.new(:ldap, gateway_opts)
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

  let(:reverse_formatter) do
    ->(key) { key.to_s.downcase.tr('-= ', '').reverse.to_sym }
  end

  let(:downcase_formatter) do
    ->(key) { key.to_s.downcase.tr('-= ', '').to_sym }
  end

  # @note Creates attribute names that can act as methods
  #
  # @see
  #
  let(:method_formatter) do
    ->(key) { ROM::LDAP::Functions.to_method_name(key) }
  end

end
