RSpec.shared_context 'people' do

  include_context 'factory'

  before do

    directory.add(
      dn: "cn=foo,#{base}",
      cn: 'foo',
      given_name: 'given_name',
      sn: 'sn',
      uid: 'uid',
      gid_number: 1,
      uid_number: 1,
      apple_imhandle: 'apple_imhandle',
      mail: 'mail',
      user_password: 'user_password',
      object_class: %w[extensibleObject person]
    )


    conf.relation(:people) do
      schema('(objectClass=person)', infer: true)
    end


    factories.define(:person, relation: :people) do |f|

      f.create_timestamp ''
      f.creators_name ''
      f.entry_csn ''
      f.entry_dn ''
      f.entry_parent_id ''
      f.entry_uuid ''
      f.nb_children ''
      f.nb_subordinates ''
      f.subschema_subentry ''

      f.pwd_history ''

      f.object_class %w[inetOrgPerson extensibleObject apple-user]

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
        "cn=#{cn},ou=specs,dc=example,dc=com"
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

    directory.delete("cn=foo,#{base}")
  end


  let(:people) { relations[:people] }

  after do
    people.delete
  end


end
