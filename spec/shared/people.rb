RSpec.shared_context 'people' do

  include_context 'factory'

  before do

    # TODO: check for essential custom non-standard attribute


    # Requires 'apple' and 'posix' schemas to be loaded into LDAP.
    #
    directory.add(
      dn: "cn=person,#{base}",
      cn: 'person',
      given_name: 'given_name',
      sn: 'sn',
      uid: 'uid',
      mail: 'mail',
      user_password: 'user_password',
      gid_number: 1,                      # not apacheds standard attribute
      uid_number: 1,                      # not apacheds standard attribute
      apple_imhandle: 'apple_imhandle',   # not apacheds standard attribute
      object_class: %w[extensibleObject person]
    )

    conf.relation(:people) do
      schema('(objectClass=person)', infer: true)
      # do
        # when the schema is only inferred and therefore has read values for attributes
        # select_label stops working
        # attribute :uid_number, ROM::LDAP::Types::Integer, read: ROM::LDAP::Types::Integer
        # attribute :cn,         ROM::LDAP::Types::String
      # end
    end


    factories.define(:person, relation: :people) do |f|

      f.object_class %w[inetOrgPerson extensibleObject]

      f.uid_number do
        fake(:number)
      end

      f.gid_number do
        fake(:number)
      end

      f.given_name do
        fake(:name, :first_name)
      end

      f.sn do
        fake(:name, :last_name)
      end

      f.cn do |given_name, sn|
        "#{given_name} #{sn}"
      end

      f.dn do |cn|
        "cn=#{cn},ou=specs,dc=rom,dc=ldap"
      end

      f.uid do |cn|
        fake(:internet, :username, cn, '_')
      end

      f.mail do |cn|
        fake(:internet, :safe_email, cn)
      end

      f.apple_imhandle do |uid|
        "@#{uid}"
      end

      f.user_password do |uid|
        ROM::LDAP::Directory::Password.generate(:sha, uid.reverse)
      end

      f.trait :foo do |t|
        t.object_class %w''
      end

    end

    directory.delete("cn=person,#{base}")
  end


  let(:people) { relations[:people] }

  after do
    people.delete
  end


end
