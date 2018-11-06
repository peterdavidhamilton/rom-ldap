RSpec.describe ROM::LDAP::FilterError do

  include_context 'directory'

  context 'valid filter' do
    before do
      conf.relation(:foo) { schema('(dn=*)', infer: true) }
    end

    it 'raises no error' do
      expect { container.relations }.not_to raise_error
    end
  end


  context 'invalid filter' do
    before do
      conf.relation(:foo) { schema('invalid', infer: true) }
    end

    it 'raises filter error' do
      expect { container.relations }.
        to raise_error(ROM::LDAP::FilterError, "'invalid' is not an LDAP filter")
    end
  end

end
