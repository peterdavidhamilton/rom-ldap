RSpec.shared_context 'directory setup' do

  let(:params) do
    { server: '127.0.0.1:10389', username: nil, password: nil }
  end

  let(:directory_options) do
    { base: 'ou=users,dc=example,dc=com' }
  end

  let(:conn) do
    ROM::LDAP::Connection.new(server: '127.0.0.1:10389')
  end

  # let(:conf)      { TestConfiguration.new(:ldap, conn) }
  let(:conf)      { ROM::Configuration.new(:ldap, params, directory_options) }
  let(:container) { ROM.container(conf) }
  let(:relations) { container.relations }
  # let(:commands)  { container.commands }
  let(:factories) { ROM::Factory.configure { |conf| conf.rom = container }}

  let(:old_format_proc) {
    ->(key) {
      key = key.to_s.downcase.tr('-', '')
      key = key[0..-2] if key[-1] == '='
      key.to_sym
    }
  }

  let(:formatter) { nil }


  # TODO: divide relation before block up.
  before do
    ROM::LDAP::Directory::Entity.use_formatter(formatter)

    conf.relation(:accounts) do
      schema('(&(objectclass=person)(uid=*))', as: :accounts, infer: true)
      use :pagination
      per_page 4
      auto_struct false
    end

    conf.relation(:group9998) do
      schema('(&(objectclass=person)(gidnumber=9998))', as: :customers, infer: true)
      use :auto_restrictions
      auto_struct false
    end

    conf.relation(:group9997) do
      schema('(&(objectclass=person)(gidnumber=9997))', as: :sandbox, infer: true)
      auto_struct false
    end

    conf.relation(:staff) do
      schema('(&(objectclass=person)(uidnumber>=1000))', as: :colleagues, infer: true) do
        attribute :uidnumber, ROM::LDAP::Types::Serial
      end
      auto_struct false
    end
  end
end
