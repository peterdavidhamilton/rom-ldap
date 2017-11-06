module ContainerSetup

  let(:params) {
    {
      server:   '127.0.0.1:10389',
      # base:     'ou=users,dc=example,dc=com',
      username: nil,
      password: nil
    }
  }

  let(:conn)      {
    @conn = ROM::LDAP::Connection.new(server: '127.0.0.1:10389')
    @conn.directory_options = { base: 'ou=users,dc=example,dc=com' }
    @conn
  }
  # let(:conf)      { TestConfiguration.new(:ldap, conn) }

  let(:conf)      { ROM::Configuration.new(:ldap, params) }
  let(:container) { ROM.container(conf) }
  let(:relations) { container.relations }
  # let(:commands)  { container.commands }
  let(:factories) { ROM::Factory.configure { |config| config.rom = container }}

  before do
    # everyone
    conf.relation(:accounts) do
      schema('(&(objectclass=person)(uid=*))', infer: true) do
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
