require 'spec_helper'

#
# Entity.use_formatter(proc) defines the proc that
# will rename an entity's attributes name
#
RSpec.describe ROM::LDAP::Directory::Entity do
  include_context 'relations'

  describe 'Entity.formatter' do

    let(:attributes) { accounts.schema.to_h.keys }

    describe 'when nil' do
      it 'uses the actual attribute name like "gidNumber" or "apple-imhandle"' do
        keys = %w[apple-imhandle cn dn gidNumber givenName
                  mail objectClass sn uid uidNumber userPassword]
        expect(attributes).to eq(keys)
      end
    end

    describe 'when mimicking Net::LDAP' do
      let(:formatter) { downcase_proc }

      it 'produces lowercase symbol attribute names like :gidnumber' do
        keys = %i[appleimhandle cn dn gidnumber givenname
                  mail objectclass sn uid uidnumber userpassword]
        expect(attributes).to eq(keys)
      end
    end

    describe 'when using the default rom-ldap formatter' do
      let(:formatter) { method_name_proc }

      it 'produces snake_case symbol attribute names like :gid_number' do
        keys = %i[apple_imhandle cn dn gid_number given_name
                  mail object_class sn uid uid_number user_password]
        expect(attributes).to eq(keys)
      end
    end

    describe 'when using a "reverse formatter"' do
      let(:formatter) { reverse_proc }

      it 'produces names like :rebmundig' do
        keys = %i[diu drowssapresu eldnahmielppa emannevig liam nc nd ns
                  rebmundig rebmundiu ssalctcejbo]
        expect(attributes).to eq(keys)
      end
    end
  end
end
