RSpec.describe ROM::LDAP::LDIF, 'import ldif' do


  let(:output) { ROM::LDAP::LDIF(input) }

  context 'when attribute has multiple values' do
    let(:input) do
      <<~EOF
      objectClass: extensibleObject
      objectClass: inetOrgPerson
      objectClass: organizationalPerson
      objectClass: person
      objectClass: top
      EOF
    end

    it 'they make an array' do
      expect(output).to eql([{
        "objectClass" => [
          "extensibleObject",
          "inetOrgPerson",
          "organizationalPerson",
          "person",
          "top"
        ],
      }])
    end
  end


  context 'when entry has comments' do
    let(:input) do
      <<~EOF
      # This is a comment
      dn: uid=spider-woman, ou=users, dc=rom, dc=ldap
      cn: Spider Woman
      # @see Martha "Mattie" Franklin
      uid: spider-woman
      uidNumber: 420
      # Earth-616
      gidNumber: 616
      EOF
    end


    it 'they are ignored' do
      expect(output).to eql([{
        :dn         => "uid=spider-woman, ou=users, dc=rom, dc=ldap",
        "cn"        => "Spider Woman",
        "gidNumber" => "616",
        "uid"       => "spider-woman",
        "uidNumber" => "420"
      }])
    end
  end



  context 'when attribute has missing values' do
    let(:input) do
      <<~EOF
      dn: uid=spider-woman, ou=users, dc=rom, dc=ldap
      cn:
      uid: spider-woman
      sn:
      givenName: Jessica
      EOF
    end

    it 'empty strings are returned' do
      expect(output).to eql([{
        :dn         => "uid=spider-woman, ou=users, dc=rom, dc=ldap",
        "cn"        => "",
        "uid"       => "spider-woman",
        "sn"        => "",
        "givenName" => "Jessica"
      }])
    end
  end



  context 'when entry includes some encoded attributes' do
    let(:input) do
      <<~EOF
      dn: uid=spider-woman, ou=users, dc=rom, dc=ldap
      cn: Spider Woman
      givenName: Jessica
      mail: arachnophilia@newavengers.stark.net
      objectClass: extensibleObject
      objectClass: inetOrgPerson
      objectClass: organizationalPerson
      objectClass: person
      objectClass: top
      sn: Drew
      uid: spider-woman
      userPassword:: e1NIQX1lZ0QyWEdPVERHK3pTVFArMFJzdUttM1JabjA9
      EOF
    end

    it 'they are untouched' do
      expect(output).to eql([{
        :dn             => "uid=spider-woman, ou=users, dc=rom, dc=ldap",
        "cn"            => "Spider Woman",
        "givenName"     => "Jessica",
        "mail"          => "arachnophilia@newavengers.stark.net",
        "objectClass"   => [
                              "extensibleObject",
                              "inetOrgPerson",
                              "organizationalPerson",
                              "person",
                              "top"
                            ],
        "sn"            => "Drew",
        "uid"           => "spider-woman",
        "userPassword"  => "e1NIQX1lZ0QyWEdPVERHK3pTVFArMFJzdUttM1JabjA9"
      }])
    end
  end




  context 'when entry has boolean values' do
    let(:input) do
      <<~EOF
      fooBar: TRUE
      EOF
    end

    it 'TrueClass or FalseClass are returned' do
      expect(output).to eql([{
        "fooBar" => true
      }])
    end
  end



  context 'when entry includes path to a binary file' do
    let(:input) do
      <<~EOF
      jpegPhoto: <file://#{SPEC_ROOT}/fixtures/pixel.jpg
      EOF
    end

    it 'reads in file data' do
      expect(output).to eql([{
        "jpegPhoto" => "\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00\xFF\xDB\x00C\x00\x03\x02\x02\x02\x02\x02\x03\x02\x02\x02\x03\x03\x03\x03\x04\x06\x04\x04\x04\x04\x04\b\x06\x06\x05\x06\t\b\n\n\t\b\t\t\n\f\x0F\f\n\v\x0E\v\t\t\r\x11\r\x0E\x0F\x10\x10\x11\x10\n\f\x12\x13\x12\x10\x13\x0F\x10\x10\x10\xFF\xC0\x00\v\b\x00\x01\x00\x01\x01\x01\x11\x00\xFF\xC4\x00\x14\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\t\xFF\xC4\x00\x14\x10\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xFF\xDA\x00\b\x01\x01\x00\x00?\x00T\xDF\xFF\xD9".b
      }])
    end
  end


  context 'when it is a version number' do
    let(:input) do
      <<~EOF
      version: 1
      EOF
    end

    it 'it is ignored' do
      expect(output).to eql([])
    end
  end


  context 'when LDIF is an update statement' do
    let(:input) do
      <<~EOF
      dn: cn=schema
      changetype: modify
      add: attributeTypes
      attributeTypes: (
      1.3.6.1.4.1.18055.0.4.1.2.1001
      NAME 'species'
      DESC 'The scientific name of the animal'
      EQUALITY caseIgnoreMatch
      SYNTAX 1.3.6.1.4.1.1466.115.121.1.15
      SINGLE-VALUE
      X-ORIGIN 'rom-ldap taxonomy'
      X-SCHEMA-FILE 'wildlife_attributes.ldif'
      )
      EOF
    end

    it 'raise SystemExit error' do
      expect{ output }.to raise_error(SystemExit, 'update statements not allowed')
    end
  end


  context 'with a block' do
    let(:input) do
      <<~EOF
      uid: spider-woman

      uid: spider-man

      uid: spider-girl

      uid: spider-gwen

      uid: silk
      EOF
    end

    it 'yields tuples' do
      yielded = []

      ROM::LDAP::LDIF(input) { |t| yielded << t }

      expect(yielded).to eql([
        { 'uid' => 'spider-woman' },
        { 'uid' => 'spider-man'   },
        { 'uid' => 'spider-girl'  },
        { 'uid' => 'spider-gwen'  },
        { 'uid' => 'silk'         }
      ])
    end
  end

end
