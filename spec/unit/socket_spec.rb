RSpec.xdescribe ROM::LDAP::Socket do

  include_context 'vendor', 'open_ldap'

  # let(:ca_file) do
  #   ENV.fetch('CA_FILE') do
  #     if File.exist?('/etc/ssl/certs/cacert.pem')
  #       '/etc/ssl/certs/cacert.pem'
  #     else
  #       SPEC_ROOT.join('fixtures/cacert.pem').to_s
  #     end
  #   end
  # end

  # let(:ssl) do
  #   OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
  # end

  # let(:ssl) do
  #   { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  # end

  # let(:ssl) do
  #   OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.merge(ca_file: ca_file)
  # end

  # let(:ssl) do
  #   { verify_mode: OpenSSL::SSL::VERIFY_PEER, ca_file: ca_file }
  # end

  # it 'default ssl' do
  #   directory
  # end

  describe 'OpenLDAP unix path' do


    let(:sock) do
      described_class.new(path: socket_path.to_s)
    end

    let(:gateway) do
      TestConfiguration.new(:ldap, "ldap://#{socket_path}").gateways[:default]
    end

    # volumes:
    #   - ../tmp/openldap:/var/run
    context 'valid socket' do
      # /var/run/ldapi
      let(:socket_path) do
        SPEC_ROOT.join('../tmp/openldap/ldapi')
      end

      it do
        expect(gateway.directory.env.to_h).to match(
          a_hash_including(path: include('/tmp/openldap/ldapi') ))
      end

      it do
        expect(gateway.directory.vendor).to eq(%w'OpenLDAP 0.0')
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
      let(:socket_path) do
        '/tmp/unknown/ldap.sock'
      end

      it 'raises error' do
        expect { sock.call }.to raise_error(
            ROM::LDAP::ConnectionError,
            'Path to unix socket is invalid - /tmp/unknown/ldap.sock'
          )
      end
    end

  end



  it do
    socket_path = SPEC_ROOT.join('../tmp/openldap/ldapi')


    rom = TestConfiguration.new(:ldap, "ldap://cn=admin,dc=rom,dc=ldap:topsecret@#{socket_path}")
    directory = rom.gateways[:default].directory
    expect(directory.env.to_h).to match(a_hash_including(path: include('/tmp/openldap/ldapi') ) )
    expect(directory.env.to_h[:host]).to eq(nil)
    expect(directory.env.to_h[:auth][:username]).to eq('cn=admin,dc=rom,dc=ldap')
    expect(directory.env.to_h[:auth][:password]).to eq('topsecret')
    expect(directory.env.base).to eq('')
    expect(directory.query(filter: '(ou=specs)', base: 'dc=rom,dc=ldap').size).to eq(1)



    rom = TestConfiguration.new(:ldap, "ldap://#{socket_path}", username: 'cn=admin,dc=rom,dc=ldap', password: 'topsecret', base: 'ou=test,dc=rom,dc=ldap')
    directory = rom.gateways[:default].directory
    expect(directory.env.to_h).to match(a_hash_including(path: include('/tmp/openldap/ldapi') ) )
    expect(directory.env.to_h[:host]).to eq(nil)
    expect(directory.env.to_h[:auth][:username]).to eq('cn=admin,dc=rom,dc=ldap')
    expect(directory.env.to_h[:auth][:password]).to eq('topsecret')
    expect(directory.env.base).to eq('ou=test,dc=rom,dc=ldap')

  end


  # FIXME: socket path is created by a volume mounted in docker-compose
  describe 'socket' do

    let(:socket_path) { SPEC_ROOT.join('../tmp/openldap/ldapi') }

    let(:uri) { "ldap://#{socket_path}" }

    include_context 'people', 'open_ldap'

    before do
      people.insert(dn: 'cn=test,ou=specs,dc=rom,dc=ldap', cn: 'test', sn: 'bar', object_class: %w'person')
    end

    it 'insert entry' do
      expect(people.count).to eql(1)
      expect(people.one).to match(a_hash_including(cn: ['test']))
    end

  end


end
