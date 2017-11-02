require 'spec_helper'

describe ROM::LDAP::ConfigError do
  include ContainerSetup

  describe 'invalid search size' do
    let(:params) do
      {
        server: '127.0.0.1:10389',
        base:   'ou=users,dc=example,dc=com',
        size:   -10
      }
    end

    it 'invalid search-size' do
      skip 'WIP'
      err = -> { container.relations }.must_raise ROM::LDAP::ConfigError
      err.message.must_match /invalid search-size/i
    end
  end

end
