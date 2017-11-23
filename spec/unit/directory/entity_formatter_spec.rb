require 'spec_helper'

#
# Entity.use_formatter(proc) defines the proc that
# will rename an entity's attributes name
#
RSpec.describe ROM::LDAP::Directory::Entity do
  describe 'Entity.formatter' do

    let(:entity) { ROM::LDAP::Directory::Entity }

    describe 'when nil' do
      let(:formatter) { nil }
      include_context 'relations'

      it 'Entity.rename works' do
        expect(entity.rename('=HELLO World')).to eql('=HELLO World')
      end

      it 'uses the actual attribute name like "gidNumber" or "apple-imhandle"' do
        keys = %w[apple-imhandle cn dn gidNumber givenName
                  mail objectClass sn uid uidNumber userPassword]
        expect(accounts.schema.to_h.keys).to eq(keys)
      end
    end

    describe 'when mimicking Net::LDAP' do
      let(:formatter) { downcase_proc }
      include_context 'relations'

      it 'Entity.rename works' do
        expect(entity.rename('=HELLO World')).to eql(:helloworld)
      end

      it 'produces lowercase symbol attribute names like :gidnumber' do
        keys = %i[appleimhandle cn dn gidnumber givenname
                  mail objectclass sn uid uidnumber userpassword]
        expect(accounts.schema.to_h.keys).to eq(keys)
      end
    end

    describe 'when using the default rom-ldap formatter' do
      let(:formatter) { method_name_proc }
      include_context 'relations'

      it 'Entity.rename works' do
        expect(entity.rename('=HELLO World')).to eql(:hello_world)
      end

      it 'produces snake_case symbol attribute names like :gid_number' do
        keys = %i[apple_imhandle cn dn gid_number given_name
                  mail object_class sn uid uid_number user_password]
        expect(accounts.schema.to_h.keys).to eq(keys)
      end
    end

    describe 'when using a "reverse formatter"' do
      let(:formatter) { reverse_proc }
      include_context 'relations'

      it 'Entity.rename works' do
        expect(entity.rename('=HELLO World')).to eql(:dlrowolleh)
      end

      it 'produces names like :rebmundig' do
        keys = %i[diu drowssapresu eldnahmielppa emannevig liam nc nd ns
                  rebmundig rebmundiu ssalctcejbo]
        expect(accounts.schema.to_h.keys).to eq(keys)
      end
    end
  end
end
