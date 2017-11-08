module ContainerSetup

  let(:params) do
    { server: '127.0.0.1:10389', username: nil, password: nil }
  end

  let(:directory_options) do
    { base: 'ou=users,dc=example,dc=com' }
  end

  let(:conn) do
    ROM::LDAP::Connection.new(server: '127.0.0.1:10389')
  end

  let(:formatter) do
    ->(key) {
      # ROM::LDAP::Functions.to_method_name(key)

      key = key.to_s.downcase
      key = key.tr('-', '')
      key = key[0..-2] if key[-1] == '='
      key.to_sym
    }
  end

  # let(:conf)      { TestConfiguration.new(:ldap, conn) }
  let(:conf)      { ROM::Configuration.new(:ldap, params, directory_options) }
  let(:container) { ROM.container(conf) }
  let(:relations) { container.relations }
  # let(:commands)  { container.commands }
  let(:factories) { ROM::Factory.configure { |conf| conf.rom = container }}

  before do

    ROM::LDAP::Directory::Entity.use_formatter(formatter)

    # everyone
    conf.relation(:accounts) do
      schema('(&(objectclass=person)(uid=*))', as: :accounts, infer: true) do
        attribute :uidnumber, ROM::LDAP::Types::Serial
      end

      use :pagination

      per_page 4
    end

    # test1..test10
    conf.relation(:group9998) do
      schema('(&(objectclass=person)(gidnumber=9998))', as: :customers, infer: true)

      use :auto_restrictions
    end

    conf.relation(:group9997) do
      schema('(&(objectclass=person)(gidnumber=9997))', as: :sandbox, infer: true) do
        attribute :uidnumber, ROM::LDAP::Types::Serial
      end
    end

    conf.relation(:staff) do # or group=9999
      schema('(&(objectclass=person)(uidnumber>=1000))', as: :colleagues, infer: true) do
        attribute :uidnumber, ROM::LDAP::Types::Serial
      end
    end
  end
end
