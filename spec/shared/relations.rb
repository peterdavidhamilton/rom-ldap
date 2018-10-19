RSpec.shared_context 'relations' do

  include_context 'directory'

  before do
    # use_formatter(formatter)
    # ROM::LDAP.load_extensions :compatible_entry_attributes
    ROM::LDAP::Directory::Entry.use_formatter(formatter)

    conf.relation(:accounts) do
      schema('(&(objectClass=person)(uid=*))', as: :accounts, infer: true) do
        attribute :uid, ROM::LDAP::Types::String.meta(index: true)
      end
      use :pagination
      per_page 4
      auto_struct false
    end

    conf.relation(:people) do
      schema('(&(objectClass=person)(gidNumber=1))') do
        # 'string' values
        attribute :mail,          ROM::LDAP::Types::String,
          read: ROM::LDAP::Types::String
        # ['array'] values
        attribute :uid,           ROM::LDAP::Types::String
        attribute :uidnumber,     ROM::LDAP::Types::Integer.meta(primary_key: true)
        attribute :gidnumber,     ROM::LDAP::Types::Integer
        attribute :dn,            ROM::LDAP::Types::String
        attribute :userpassword,  ROM::LDAP::Types::String
        attribute :cn,            ROM::LDAP::Types::String
        attribute :givenname,     ROM::LDAP::Types::String
        attribute :sn,            ROM::LDAP::Types::String
        attribute :appleimhandle, ROM::LDAP::Types::Symbol
        attribute :objectclass,   ROM::LDAP::Types::Strings
      end

      auto_struct true
    end

    conf.relation(:group9998) do
      schema('(&(objectClass=person)(gidNumber=9998))', as: :customers, infer: true) do
        attribute :cn,        ROM::LDAP::Types::String.meta(index: true)
        attribute :uid,       ROM::LDAP::Types::String.meta(index: true)
        attribute :uidnumber, ROM::LDAP::Types::Integer.meta(index: true)
        attribute :givenname, ROM::LDAP::Types::String.meta(index: true)
      end
      use :auto_restrictions
      auto_struct false
    end

    # reload_attributes!
    directory.attribute_types
  end

  # memory
  let(:planets)   { container.relations[:planets]   }

  let(:accounts)  { container.relations[:accounts]  }
  let(:customers) { container.relations[:customers] }
  let(:people)    { container.relations[:people]    }

  after do
    # reset_attributes!
    directory.class.attributes = nil
  end
end
