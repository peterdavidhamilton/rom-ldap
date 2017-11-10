require 'spec_helper'

RSpec.describe ROM::LDAP::ConnectionError do

  # describe 'downed host' do
  #   let(:params) do
  #     { server: '255.255.255.255:10389', base: 'ou=users,dc=example,dc=com' }
  #   end

  #   it 'times out' do
  #     err = -> { container.relations }.must_raise ROM::LDAP::ConnectionError
  #     err.message.must_match /permission denied/i
  #   end
  # end

  # describe 'incorrect host' do
  #   let(:params) do
  #     { server: '9.9.9.9:10389', base: 'ou=users,dc=example,dc=com' }
  #   end

  #   it 'times out' do
  #     err = -> { container.relations }.must_raise ROM::LDAP::ConnectionError
  #     err.message.must_match /connection refused/i
  #   end
  # end

  # describe 'incorrect search base' do
  #   let(:params) do
  #     { server: '127.0.0.1:10389', port: 10_389, base: 'ou=foo,dc=bar' }
  #   end

  #   it 'API#directory returns nil' do
  #     err = -> { container.relations }.must_raise ROM::LDAP::ConnectionError
  #     err.message.must_match /no dataset returned/i
  #   end
  # end

  # describe 'missing search base' do
  #   let(:params) do
  #     { server: '127.0.0.1:10389' }
  #   end

  #   it 'missing search base' do
  #     err = -> { container.relations }.must_raise ROM::LDAP::ConnectionError
  #     err.message.must_match /no dataset returned/i
  #   end
  # end

  # describe 'incorrect port' do
  #   let(:params) do
  #     { server: '127.0.0.1:389', base: 'ou=users,dc=example,dc=com' }
  #   end

  #   it 'invalid base setting' do
  #     err = -> { container.relations }.must_raise ROM::LDAP::ConnectionError
  #     err.message.must_match /connection refused/i
  #   end
  # end
end
