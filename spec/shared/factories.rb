require 'rom-factory'
require 'rom/ldap/directory/password'

Faker::Config.random = Random.new(42)
Faker::Config.locale = :en

RSpec.shared_context 'factories' do
  include_context 'relations'

  let(:factories) do
    ROM::Factory.configure { |conf| conf.rom = container }
  end

  let(:user_names) { [Faker::Internet.unique.user_name] }

  before do
    factories.define(:person, relation: :people) do |f|
      f.uid           'foo'
      f.gidnumber     1
      f.sequence(:uidnumber) { |n| n * n }
      f.dn            'uid=foo,ou=users,dc=example,dc=com'
      f.userpassword  ROM::LDAP::Directory::Password.generate(:sha, 'foo')
      f.cn            { fake(:name, :name_with_middle) }
      f.givenname     { fake(:name, :first_name) }
      f.sn            { fake(:name, :last_name) }
      f.appleimhandle { '@foo' }
      f.mail          { fake(:internet, :safe_email, 'foo') }
      f.objectclass   %w[inetOrgPerson extensibleObject apple-user]
    end

    user_names.each do |uid|
      factories[:person,
                uid: uid,
                dn: "uid=#{uid},ou=users,dc=example,dc=com",
                appleimhandle: "@#{uid}",
                mail: "#{uid}@example.com"
      ]
    end
  end

  after do
    user_names.each { |uid| accounts.where(uid: uid).delete }
  end

end
