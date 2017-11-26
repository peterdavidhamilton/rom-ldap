RSpec.shared_context 'relations' do

  include_context 'directory'

  before do
    # use_formatter(formatter)
    ROM::LDAP::Directory::Entry.use_formatter(formatter)

    conf.relation(:accounts) do
      schema('(&(objectClass=person)(uid=*))', as: :accounts, infer: true)
      use :pagination
      per_page 4
      auto_struct false
    end

    conf.relation(:people) do
      schema('(&(objectClass=person)(gidNumber=1))') do
        attribute :uid,           ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
        attribute :uidnumber,     ROM::LDAP::Types::Serial, read: ROM::LDAP::Types::Single::Int
        attribute :gidnumber,     ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::Int
        attribute :dn,            ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
        attribute :userpassword,  ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
        attribute :cn,            ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
        attribute :givenname,     ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
        attribute :sn,            ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
        attribute :appleimhandle, ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
        attribute :mail,          ROM::LDAP::Types::String, read: ROM::LDAP::Types::Single::String
        attribute :objectclass,   ROM::LDAP::Types::Array,  read: ROM::LDAP::Types::Multiple::String
      end

      auto_struct true
    end

    conf.relation(:group9998) do
      schema('(&(objectClass=person)(gidNumber=9998))', as: :customers, infer: true)
      use :auto_restrictions
      auto_struct false
    end

    # reload_attributes!
    relations[:accounts].dataset.directory.attribute_types
  end

  let(:accounts)  { container.relations[:accounts]  }
  let(:customers) { container.relations[:customers] }
  let(:people)    { container.relations[:people]    }

  after do
    # reset_attributes!
    ROM::LDAP::Directory.attributes = nil
  end
end
