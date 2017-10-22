require 'spec_helper'

describe ROM::LDAP::ConnectionError do
  include ContainerSetup


  describe 'downed host' do
    let(:params) do
      { host: '255.255.255.255', port: 10389, base: 'ou=users,dc=example,dc=com' }
    end

    it 'times out' do
      err = -> { container.relations }.must_raise ROM::LDAP::ConnectionError
      err.message.must_match /permission denied/i
    end
  end


  describe 'incorrect host' do
    let(:params) do
      { host: '9.9.9.9', port: 10389, base: 'ou=users,dc=example,dc=com' }
    end

    it 'times out' do
      err = -> { container.relations }.must_raise ROM::LDAP::ConnectionError
      err.message.must_match /connection refused/i
    end
  end

  describe 'incorrect search base' do
    let(:params) do
      { host: '127.0.0.1', port: 10389, base: 'ou=foo,dc=bar' }
    end

    it 'API#directory returns nil' do
      err = -> { container.relations }.must_raise ROM::LDAP::ConnectionError
      err.message.must_match /directory returned nil/i
    end
  end

  describe 'missing search base' do
    let(:params) do
      { host: '127.0.0.1', port: 10389 }
    end

    it 'missing search base' do
      err = -> { container.relations }.must_raise ROM::LDAP::ConnectionError
      err.message.must_match /directory returned nil/i
    end
  end


  describe 'incorrect port' do
    let(:params) do
      { host: '127.0.0.1', port: 389, base: 'ou=users,dc=example,dc=com' }
    end

    it 'invalid base setting' do
      err = -> { container.relations }.must_raise ROM::LDAP::ConnectionError
      err.message.must_match /connection refused/i
    end
  end

end
