module ContainerSetup

  let(:params) do
    Hash[host: '10.0.1.199',
         port: 389,
         base: 'cn=users,dc=pdh,dc=private']
  end

  # let(:conf)      { TestConfiguration.new(:ldap, conn) }
  let(:conn)      { Net::LDAP.new(params) }
  let(:conf)      { ROM::Configuration.new(:ldap, conn) }
  let(:container) { ROM.container(conf) }
  let(:relations) { container.relations }
  # let(:commands)  { container.commands }
  let(:factories) { ROM::Factory.configure { |config| config.rom = container }}

  before do
    conf.relation(:accounts) do
      schema('(uid=*)', infer: true) do
        attribute :uidnumber, ROM::LDAP::Types::Serial
      end
    end

    conf.relation(:group1050) do
      schema('(gidnumber=1050)', as: :customers, infer: true) do
        attribute :uidnumber, ROM::LDAP::Types::Serial
      end
    end

    conf.relation(:staff) do
      schema('(uidnumber>=1000)', as: :colleagues, infer: true) do
        attribute :uidnumber, ROM::LDAP::Types::Serial
      end
    end
  end
end
