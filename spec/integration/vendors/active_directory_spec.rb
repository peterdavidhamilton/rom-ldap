RSpec.describe 'Active Directory' do

  include_context 'directory'

  # let(:uri)  { 'ldap://addc4.leedsbeckett.ac.uk:389' }
  # let(:base) { 'ou=usr,dc=leedsbeckett,dc=ac,dc=uk' }


  xit 'vendor extension' do
    expect(directory.vendor_name).to eql('Microsoft')
    expect(directory.vendor_version).to eql('Windows Server 2008 R2 (6.1)')
  end


  xit 'reveals directory vendor name' do
    expect(conf.gateways[:default].directory_type).to eql(:active_directory)
  end
end
