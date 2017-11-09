require 'rom/ldap/directory/password'

RSpec.shared_context 'factories' do

  include_context 'relations'

  let(:user_name) { Faker::Internet.unique.user_name }
  let(:password)  { ROM::LDAP::Directory::Password.generate(:sha, user_name) }

  before do
    @uid = user_name

    factories.define(:account) do |f|
      f.uid  @uid
      f.dn   "uid=#{@uid},ou=users,dc=example,dc=com"
      f.cn   { fake(:name, :name_with_middle) }
      f.sn   { fake(:name, :last_name) }
      f.mail { fake(:internet, :safe_email, @uid) }
    end

    factories.define(flat_account: :account) do |f|
      f.userpassword  password
      f.uidnumber     { fake(:number, :number, 4) }
      f.gidnumber     { fake(:number, :number, 4) }
      f.givenname     { fake(:name, :first_name) }
      f.appleimhandle { '@name' }
      f.objectclass   %w[inetOrgPerson extensibleObject]
    end

    # factories.define(snake_case_account: :account) do |f|
    #   f.user_password  password
    #   f.uid_number     { fake(:number, :number, 4) }
    #   f.gid_number     { fake(:number, :number, 4) }
    #   f.given_name     { fake(:name, :first_name) }
    #   f.object_class   %w[inetOrgPerson extensibleObject apple-user]
    # end

    factories.define(customers: :account) do |f|
      f.gidnumber 9998
    end

    # factories.define(colleagues: :account) do |f|
    #   f.uidnumber { fake(:number, :between, [1001, 2000])}
    # end


    factories.define(sandbox: :account) do |f|
      f.gidnumber 9997
    end
  end

end
