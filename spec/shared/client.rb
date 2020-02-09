RSpec.shared_context 'an LDAP server' do

  describe ':add_response' do

    let(:dn) { '' }
    let(:attrs) { {} }

    subject(:pdu) { client.add(dn: dn, attrs: attrs) }

    it { expect(pdu.pdu_type).to eql(:add_response) }

    describe 'Object Class Violation' do
      let(:dn) { 'cn=class_violation,ou=specs,dc=rom,dc=ldap' }
      let(:attrs) { { cn: 'class_violation' } }

      it { expect(pdu.message).to eql('Object Class Violation') }
      it { expect(pdu.info).to include('Indicates the add, modify, or modify DN operation violates the object class rules for the entry.') }
      it { expect(pdu.success?).to be(false) }
      it { expect(pdu.matched_dn).to eql('') }
      it { expect(pdu.result_code).to eql(65) }
      it { expect(pdu.app_tag).to eql(9) }
      it { expect(pdu.result_controls).to eql([]) }
    end

    describe 'Success' do
      let(:dn) { 'ou=success,ou=specs,dc=rom,dc=ldap' }
      let(:attrs) { { ou: 'success', objectClass: 'organizationalUnit' } }

      after { client.delete(dn: dn) }

      it { expect(pdu.message).to eql('Success') }
      it { expect(pdu.info).to include('Indicates the requested client operation completed successfully.') }
      it { expect(pdu.success?).to be(true) }
      it { expect(pdu.matched_dn).to eql('') }
      it { expect(pdu.result_code).to eql(0) }
      it { expect(pdu.app_tag).to eql(9) }
      it { expect(pdu.result_controls).to eql([]) }
    end

    describe 'No Such Object' do
      let(:dn) { 'ou=no_such_object,ou=foo,dc=rom,dc=ldap' }
      let(:attrs) { { ou: 'no_such_object', objectClass: 'organizationalUnit' } }

      it { expect(pdu.message).to eql('No Such Object') }
      it { expect(pdu.info).to include('Indicates the target object cannot be found.') }
      it { expect(pdu.success?).to be(false) }
      # it { expect(pdu.matched_dn).to eql('dc=rom,dc=ldap') }
      # it { expect(pdu.matched_dn).to eql('') } # ApacheDS only
      it { expect(pdu.result_code).to eql(32) }
      it { expect(pdu.app_tag).to eql(9) }
      it { expect(pdu.result_controls).to eql([]) }
    end

    describe 'Entry Already Exists' do
      let(:dn) { 'ou=new,ou=specs,dc=rom,dc=ldap' }
      let(:attrs) { { ou: 'new', objectClass: 'organizationalUnit' } }

      before { client.add(dn: dn, attrs: attrs) }
      after { client.delete(dn: dn) }

      it { expect(pdu.message).to eql('Entry Already Exists') }
      it { expect(pdu.info).to include('Indicates the add operation attempted to add an entry that already exists') }
      it { expect(pdu.success?).to be(false) }
      it { expect(pdu.result_code).to eql(68) }
      it { expect(pdu.app_tag).to eql(9) }
      it { expect(pdu.result_controls).to eql([]) }
    end
  end

end
