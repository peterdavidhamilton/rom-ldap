RSpec.describe ROM::LDAP::Gateway do

  include_context 'directory'

  subject(:gateway) { described_class.new(uri, gateway_opts) }

  with_vendors do
    it 'connects to an LDAP server' do
      if vendor == '389_ds'
        expect(gateway.directory_type).to eql(:three_eight_nine)
      else
        expect(gateway.directory_type).to eql(vendor.to_sym)
      end
    end
  end

end
