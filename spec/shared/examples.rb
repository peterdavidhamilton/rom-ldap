class Module
  include Minitest::Spec::DSL
end

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

  before do
    conf.relation(:accounts) do
      schema('(uid=*)', infer: true)
    end

    conf.relation(:users) do
      schema('(gidnumber=1050)', as: :customers, infer: true)
    end

    conf.relation(:staff) do
      schema('(uidnumber>=1000)', as: :colleagues, infer: true)
    end
  end
end


module RelationSetup
  include ContainerSetup

  let(:accounts) { container.relations[:accounts] }
  let(:staff)    { container.relations[:staff]    }
  let(:users)    { container.relations[:users]    }
end
