require 'spec_helper'

RSpec.describe ROM::Struct do

  include_context 'relations'

  describe 'unformatted' do
    it 'produces camel-case attribute names like "gidNumber"' do
      keys = %w[apple-imhandle cn dn gidNumber givenName
                mail objectClass sn uid uidNumber userPassword]
      expect(accounts.schema.to_h.keys).to eq(keys)
    end
  end

  describe 'net-ldap formatter' do
    let(:formatter) { old_format_proc }

    it 'produces lowercase symbol attribute names like :gidnumber' do
      keys = %i[appleimhandle cn dn gidnumber givenname
                mail objectclass sn uid uidnumber userpassword]
      expect(accounts.schema.to_h.keys).to eq(keys)
    end
  end

  describe 'rom-ldap formatter' do
    let(:formatter) { ->(key) { ROM::LDAP::Functions.to_method_name(key) } }

    it 'produces snake_case symbol attribute names like :gid_number' do
      keys = %i[apple_imhandle cn dn gid_number given_name
                mail object_class sn uid uid_number user_password]
      expect(accounts.schema.to_h.keys).to eq(keys)
    end
  end
end
