RSpec.describe ROM::LDAP::ConfigError do

  describe 'invalid search size' do

    let(:gateway_opts) do
      gateway_opts.merge(size: -10)
    end

    include_context 'directory'

    xit 'invalid search-size' do
      expect { container.relations }.
        to raise_error(ROM::LDAP::ConfigError, 'size must be a positive integer')
    end
  end

end
