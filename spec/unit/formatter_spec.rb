RSpec.describe ROM::LDAP, 'schema formatting' do

  include_context 'directory'

  before do
    directory.add(
      dn: "cn=Henry McCoy,#{base}",
      cn: 'Henry McCoy',
      given_name: 'Henry',
      sn: 'McCoy',
      uid: 'hank',
      gid_number: 666,
      uid_number: 666,
      apple_imhandle: '@beast',
      mail: 'beast@x-men.com',
      object_class: %w[extensibleObject person]
    )
  end


  after do
    directory.delete("cn=Henry McCoy,#{base}")
  end

  context 'when using the default ROM-LDAP formatter proc' do

    before do
      ROM::LDAP.use_formatter(method_formatter)

      conf.relation(:compatible) { schema('(uid=*)', infer: true) }
    end

    let(:attributes) { relations[:compatible].schema.to_h.keys }

    it { expect(ROM::LDAP.formatter.inspect).to match(/to_method_name/) }

    it 'creates attribute names compatible with Ruby methods' do
      expect(ROM::LDAP.formatter['=HELLO World']).to eql(:hello_world)

      expect(attributes).to include(*%i[
                                      apple_imhandle
                                      cn
                                      dn
                                      gid_number
                                      given_name
                                      mail
                                      object_class
                                      sn
                                      uid
                                      uid_number
                                    ])
    end
  end

  # NB: ROM Attribute#name must now be a symbol
  #
  context 'when formatter proc is default or nil' do
    before do
      ROM::LDAP.use_formatter(nil)

      conf.relation(:unformatted) { schema('(mail=*)', infer: true) }
    end

    let(:attributes) { relations[:unformatted].schema.map(&:name) }

    it { expect(ROM::LDAP.formatter.to_s).to match(/formatter.rb:6/) }

    it 'has no effect, leaving attribute name unaltered' do

      expect(ROM::LDAP.formatter['=HELLO World']).to eql('=HELLO World')

      expect(attributes).to include(*%i[
                                        apple-imhandle
                                        cn
                                        dn
                                        gidNumber
                                        givenName
                                        mail
                                        objectClass
                                        sn
                                        uid
                                        uidNumber
                                      ])
    end
  end



  context 'when formatter proc emulates Net::LDAP' do

    before do
      ROM::LDAP.use_formatter(downcase_formatter)

      conf.relation(:downcase) { schema('(sn=*)', infer: true) }
    end

    let(:attributes) { relations[:downcase].schema.to_h.keys }

    it { expect(ROM::LDAP.formatter.to_s).to match(/directory.rb:21/) }


    it 'creates lowercase symbols' do
      expect(ROM::LDAP.formatter['=HELLO World']).to eql(:helloworld)

      expect(attributes).to include(*%i[
                                      appleimhandle
                                      cn
                                      dn
                                      gidnumber
                                      givenname
                                      mail
                                      objectclass
                                      sn
                                      uid
                                      uidnumber
                                    ])
    end
  end


  context 'when using a custom formatter' do

    before do
      ROM::LDAP.use_formatter(reverse_formatter)

      conf.relation(:reverse) { schema('(givenname=*)', infer: true) }
    end

    let(:attributes) { relations[:reverse].schema.to_h.keys }

    it { expect(ROM::LDAP.formatter.to_s).to match(/directory.rb:17/) }

    it 'calls the formatter proc' do
      expect(ROM::LDAP.formatter['=HELLO World']).to eql(:dlrowolleh)

      expect(attributes).to include(*%i[
                                      diu
                                      eldnahmielppa
                                      emannevig
                                      liam
                                      nc
                                      nd
                                      ns
                                      rebmundig
                                      rebmundiu
                                      ssalctcejbo
                                    ])
    end
  end

end
