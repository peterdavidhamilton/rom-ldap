require 'webmock/rspec'

WebMock.disable_net_connect! # (allow_localhost: true)

RSpec.describe ROM::LDAP::Socket do

  describe 'host:port' do
    let(:sock) { described_class.new(host: 'apacheds', port: 10389) }

    it 'takes options' do
      expect(sock).to respond_to(:options)
      expect(sock.options[:host]).to eql('apacheds')
      expect(sock.options[:port]).to eql(10389)
      expect(sock.options[:path]).to eql(nil)
      expect(sock.options[:read_timeout]).to eql(20)
      expect(sock.options[:write_timeout]).to eql(10)
      expect(sock.options[:retry_count]).to eql(3)
      expect(sock.options[:keep_alive]).to eql(true)
      expect(sock.options[:buffered]).to eql(true)
    end

    it '#call returns a socket' do
      expect(sock.call).to be_an_instance_of(::Socket)
    end
  end

  describe 'unix path' do
    # context 'valid socket' do
    #   let(:sock) { described_class.new(path: '/var/run/slapd/ldapi') }

    #   it 'takes options' do
    #     expect(sock).to respond_to(:options)
    #     expect(sock.options[:host]).to eql(nil)
    #     expect(sock.options[:port]).to eql(nil)
    #     expect(sock.options[:path]).to eql('/var/run/slapd/ldapi')
    #     expect(sock.options[:timeout]).to eql(10)
    #     expect(sock.options[:keep_alive]).to eql(true)
    #     expect(sock.options[:buffered]).to eql(true)
    #   end

    #   it '#call returns a socket' do
    #     expect(sock.call).to be_an_instance_of(::Socket)
    #   end
    # end

    context 'invalid socket' do
      let(:sock) { described_class.new(path: '/var/apacheds/rom.sock') }

      it 'raises error' do
        expect { sock.call }.to raise_error(
            ROM::LDAP::ConnectionError,
            'Path to unix socket is invalid - /var/apacheds/rom.sock'
          )
      end
    end
  end
end
