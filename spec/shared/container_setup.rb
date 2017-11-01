module ContainerSetup

  let(:params) do
    Hash[host: '127.0.0.1',
         port: 10389,
         base: 'ou=users,dc=example,dc=com']
  end

  # let(:conf)      { TestConfiguration.new(:ldap, conn) }
  let(:conn)      { Net::LDAP.new(params) }
  let(:conf)      { ROM::Configuration.new(:ldap, conn) }
  let(:container) { ROM.container(conf) }
  let(:relations) { container.relations }
  # let(:commands)  { container.commands }
  let(:factories) { ROM::Factory.configure { |config| config.rom = container }}

  before do
    # everyone
    conf.relation(:accounts) do
      schema('(uid=*)', infer: true) do
        attribute :uidnumber, ROM::LDAP::Types::Serial
      end

      use :pagination

      per_page 4
    end

    # test1..test10
    conf.relation(:group9998) do
      schema('(gidnumber=9998)', as: :customers, infer: true) do
        # attribute :uidnumber, ROM::LDAP::Types::Serial
      end

      use :auto_restrictions
    end

    conf.relation(:group9997) do
      schema('(gidnumber=9997)', as: :sandbox, infer: true) do
        attribute :uidnumber, ROM::LDAP::Types::Serial
      end
    end

    conf.relation(:staff) do # or group=9999
      schema('(uidnumber>=1000)', as: :colleagues, infer: true) do
        attribute :uidnumber, ROM::LDAP::Types::Serial
      end
    end
  end
end
