RSpec.describe ROM::LDAP, 'schema formatting' do

  with_vendors do

    before do
      directory.add(
        dn: "cn=Henry McCoy,#{base}",
        cn: 'Henry McCoy',
        given_name: 'Henry',
        sn: 'McCoy',
        uid: 'hank',
        gid_number: 666,
        uid_number: 666,
        mail: 'beast@x-men.com',
        object_class: %w[extensibleObject person]
      )
    end


    after do
      directory.delete("cn=Henry McCoy,#{base}")
    end


    context 'when using #to_method_name proc' do

      before do
        ROM::LDAP.use_formatter(method_formatter)

        conf.relation(:compatible) { schema('(uid=*)', infer: true) }
      end

      let(:attributes) { relations[:compatible].schema.to_h.keys }

      it 'creates attribute names compatible with Ruby methods' do
        expect(ROM::LDAP.formatter['=HELLO World']).to eql(:hello_world)

        expect(attributes).to include(*%i[
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
    context 'when using no formatter proc' do
      before do
        ROM::LDAP.use_formatter(nil)

        conf.relation(:unformatted) { schema('(mail=*)', infer: true) }
      end

      let(:attributes) { relations[:unformatted].schema.map(&:name) }

      it 'has no effect, leaving attribute name unaltered' do

        expect(ROM::LDAP.formatter['=HELLO World']).to eql('=HELLO World')

        expect(attributes).to include(*%i[
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



    context 'when using #downcase formatter proc' do

      before do
        ROM::LDAP.use_formatter(downcase_formatter)

        conf.relation(:downcase) { schema('(sn=*)', infer: true) }
      end

      let(:attributes) { relations[:downcase].schema.to_h.keys }

      it 'creates lowercase symbols' do
        expect(ROM::LDAP.formatter['=HELLO World']).to eql(:helloworld)

        expect(attributes).to include(*%i[
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


    context 'when using #reverse formatter proc' do

      before do
        ROM::LDAP.use_formatter(reverse_formatter)

        conf.relation(:reverse) { schema('(givenname=*)', infer: true) }
      end

      let(:attributes) { relations[:reverse].schema.to_h.keys }

      it 'calls the formatter proc' do
        expect(ROM::LDAP.formatter['=HELLO World']).to eql(:dlrowolleh)

        expect(attributes).to include(*%i[
                                        diu
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
end
