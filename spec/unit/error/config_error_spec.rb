RSpec.describe ROM::LDAP::ConfigError do

  include_context 'directory'

  describe 'invalid search size' do

    # let(:conf) do
    #   ROM::Configuration.new(:ldap, uri, gateway_opts.merge(size: -10))
    # end

    let(:gateway_opts) do
      { size: -10 }
    end

    xit 'invalid search-size' do
      expect { container.relations }.to raise_error(
        ROM::LDAP::ConfigError,
        'size must be a positive integer'
      )
    end
  end

end
