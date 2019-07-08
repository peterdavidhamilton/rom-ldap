RSpec.shared_context 'directory' do

  #
  # Example functions to format attributes.
  #
  # @note Creates attribute names that can act as methods
  #
  # @see ROM::LDAP.load_extensions(:compatibility)
  #
  let(:method_formatter) do
    ROM::LDAP::Functions[:to_method_name]
  end

  # @note formatter_spec.rb checks for line numbers :57 and :61.
  #
  let(:reverse_formatter) do
    ->(key) { key.to_s.downcase.tr('-= ', '').reverse.to_sym }
  end

  let(:downcase_formatter) do
    ->(key) { key.to_s.downcase.tr('-= ', '').to_sym }
  end

  let(:base) { 'ou=specs,dc=rom,dc=ldap' }

  let(:uri) { ENV['LDAPURI'] || "ldap://apacheds:10389/#{base}" }

  let(:bind_dn) { 'uid=admin,ou=system' }

  let(:bind_pw) { 'secret' }

  let(:logger) { Logger.new(File.open('./log/test.log', 'a')) }

  let(:gateway_opts) do
    { username: bind_dn, password: bind_pw, logger: logger }
  end

  let(:conf) { TestConfiguration.new(:ldap, uri, gateway_opts) }

  let(:container) { ROM.container(conf) }

  let(:directory) { conf.gateways[:default].directory }

  let(:client) { directory.client }

  let(:relations) { container.relations }

  let(:commands) { container.commands }

  before { ROM::LDAP.use_formatter(method_formatter) }

  after { ROM::LDAP.use_formatter(nil) }
end
