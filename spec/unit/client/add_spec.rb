RSpec.describe ROM::LDAP::Client, '#add' do

  context '389DS' do
    include_context 'vendor', '389_ds'

    it_behaves_like 'an LDAP server'
  end


  context 'OpenDJ' do
    include_context 'vendor', 'open_dj'

    it_behaves_like 'an LDAP server'
  end



  context 'ApacheDS' do
    include_context 'vendor', 'apache_ds'

    it_behaves_like 'an LDAP server'

    describe 'No Such Attribute' do
      subject(:pdu) { client.add(dn: dn, attrs: attrs) }

      let(:dn) { 'cn=no_such_attribute,ou=specs,dc=rom,dc=ldap' }
      let(:attrs) { { cn: 'no_such_attribute', object___class: 'top' } }

      it { expect(pdu.message).to eql('No Such Attribute') }
      it { expect(pdu.info).to include('Indicates the attribute specified in the modify or compare operation does not exist in the entry.') }
      it { expect(pdu.success?).to be(false) }
      it { expect(pdu.result_code).to eql(16) }
      it { expect(pdu.app_tag).to eql(9) }
      it { expect(pdu.result_controls).to eql([]) }
    end
  end


  context 'OpenLDAP' do
    include_context 'vendor', 'open_ldap'

    it_behaves_like 'an LDAP server'

    context 'Unwilling To Perform' do
      subject(:pdu) { client.add(dn: dn, attrs: attrs) }

      let(:dn) { 'ou=no_such_object,ou=specs,dc=example,dc=com' }
      let(:attrs) { { ou: 'no_such_object', objectClass: 'organizationalUnit' } }

      it { expect(pdu.message).to eql('Unwilling To Perform') }
      it { expect(pdu.info).to include('Indicates the LDAP server cannot process the request because of server-defined restrictions.') }
      it { expect(pdu.success?).to be(false) }
      it { expect(pdu.matched_dn).to eql('') }
      it { expect(pdu.result_code).to eql(53) }
      it { expect(pdu.app_tag).to eql(9) }
      it { expect(pdu.result_controls).to eql([]) }
    end
  end

end
