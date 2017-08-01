module RelationSetup
  include ContainerSetup

  let(:accounts)   { container.relations[:accounts] }
  let(:customers)  { container.relations[:customers]    }
  let(:colleagues) { container.relations[:colleagues]    }

  before do
    user_name = Faker::Internet.unique.user_name

    factories.define(:account) do |f|
      f.uid           user_name
      f.dn            "uid=#{user_name},ou=users,dc=example,dc=com"
      f.userpassword  Net::LDAP::Password.generate(:sha, user_name)
      f.uidnumber     { fake(:number, :number, 4) }
      f.gidnumber     { fake(:number, :number, 4) }
      f.cn            { fake(:name, :name_with_middle) }
      f.givenname     { fake(:name, :first_name) }
      f.sn            { fake(:name, :last_name) }
      f.mail          { fake(:internet, :safe_email, user_name) }
      f.objectclass   %w[inetorgperson extensibleobject]
    end

    factories.define(customers: :account) do |f|
      f.gidnumber 1050
    end

    factories.define(colleagues: :account) do |f|
      f.uidnumber { fake(:number, :between, [1001, 2000])}
    end
  end
end