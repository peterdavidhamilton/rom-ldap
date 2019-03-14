RSpec.describe ROM::LDAP::Client, '#add' do

  include_context 'directory'

  before do
    directory.add(
      dn: 'ou=specs,dc=rom,dc=ldap',
      ou: 'specs',
      objectClass: 'organizationalUnit'
    )
  end

  it 'raises error if invalid' do
    expect {
      client.add(dn: 'dc=foo', attrs: {})
    }.to raise_error(ROM::LDAP::ResponseMissingOrInvalidError, 'Invalid add_response')
  end


  describe ':add_response' do

    let(:dn) { '' }
    let(:attrs) { {} }

    subject(:pdu) { client.add(dn: dn, attrs: attrs) }

    it { expect(pdu.pdu_type).to eql(:add_response) }

    context 'Object Class Violation' do
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

    context 'No Such Attribute' do
      let(:dn) { 'cn=no_such_attribute,ou=specs,dc=rom,dc=ldap' }
      let(:attrs) { { cn: 'no_such_attribute', object___class: 'top' } }

      it { expect(pdu.message).to eql('No Such Attribute') }
      it { expect(pdu.info).to include('Indicates the attribute specified in the modify or compare operation does not exist in the entry.') }
      it { expect(pdu.success?).to be(false) }
      it { expect(pdu.result_code).to eql(16) }
      it { expect(pdu.app_tag).to eql(9) }
      it { expect(pdu.result_controls).to eql([]) }
    end

    context 'Success' do
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


    context 'No Such Object' do
      let(:dn) { 'ou=no_such_object,ou=specs,dc=example,dc=com' }
      let(:attrs) { { ou: 'no_such_object', objectClass: 'organizationalUnit' } }

      it { expect(pdu.message).to eql('No Such Object') }
      it { expect(pdu.info).to include('Indicates the target object cannot be found.') }
      it { expect(pdu.success?).to be(false) }
      it { expect(pdu.matched_dn).to eql('') }
      it { expect(pdu.result_code).to eql(32) }
      it { expect(pdu.app_tag).to eql(9) }
      it { expect(pdu.result_controls).to eql([]) }
    end


    context 'Entry Already Exists' do
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
