RSpec.xdescribe ROM::LDAP::Socket do

  include_context 'vendor', 'open_ldap'

  let(:ca_file) do
    ENV.fetch('CA_FILE') do
      if File.exist?('/etc/ssl/certs/cacert.pem')
        '/etc/ssl/certs/cacert.pem'
      else
        SPEC_ROOT.join('fixtures/cacert.pem').to_s
      end
    end
  end

  # let(:ssl) do
  #   OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
  # end

  # let(:ssl) do
  #   { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  # end

  let(:ssl) do
    OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.merge(ca_file: ca_file)
  end

  # let(:ssl) do
  #   { verify_mode: OpenSSL::SSL::VERIFY_PEER, ca_file: ca_file }
  # end

  it 'default ssl' do
    directory
  end

  xdescribe 'OpenLDAP unix path' do

    context 'valid socket' do
      # let(:sock) { described_class.new(path: '/var/run/slapd/ldapi') }

      let(:socket_path) do
        # /var/run/slapd/ldapi
        SPEC_ROOT.join('../tmp/socket/ldapi').to_s
      end

      let(:gateway) do
        TestConfiguration.new(:ldap, "ldap://#{socket_path}").gateways[:default]
      end

      let(:sock) do
        described_class.new(path: socket_path)
      end

      it do
        binding.pry
        gateway
      end

      # it 'takes options' do
      #   expect(sock).to respond_to(:options)
      #   expect(sock.options[:host]).to eql(nil)
      #   expect(sock.options[:port]).to eql(nil)
      #   expect(sock.options[:path]).to eql('/var/run/slapd/ldapi')
      #   expect(sock.options[:timeout]).to eql(10)
      #   expect(sock.options[:keep_alive]).to eql(true)
      #   expect(sock.options[:buffered]).to eql(true)
      # end

      # it '#call returns a socket' do
      #   expect(sock.call).to be_an_instance_of(::Socket)
      # end

    end

    context 'invalid socket path' do
      let(:sock) { described_class.new(path: '/tmp/unknown/rom.sock') }

      it 'raises error' do
        expect { sock.call }.to raise_error(
            ROM::LDAP::ConnectionError,
            'Path to unix socket is invalid - /tmp/unknown/rom.sock'
          )
      end
    end
  end
end
