RSpec.shared_context 'people' do |vendor|

  include_context 'factory', vendor

  before do
    directory.add(
      dn: "cn=person,#{base}",
      cn: 'person',
      given_name: 'given_name',
      sn: 'sn',
      uid: 'uid',
      mail: 'mail',
      user_password: 'user_password',
      gid_number: 1,
      uid_number: 1,
      object_class: %w[extensibleObject person]
    )

    conf.relation(:people) do
      schema('(objectClass=person)', infer: true)
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

      # OpenDJ
      #
      # Pre-encoded passwords are not allowed for the password attribute userPassword
      f.user_password do |uid|
        uid.reverse
        # ROM::LDAP::Directory::Password.generate(:sha, uid.reverse)
      end


      f.trait :sequence do |t|
        t.sequence(:uid_number) { |i| i }
        t.uid { |uid_number| "user#{uid_number}" }
        t.cn { |uid| uid.upcase }
      end
    end

    directory.delete("cn=person,#{base}")
  end


  let(:people) { relations[:people] }

  after do
    people.delete
  end

end
