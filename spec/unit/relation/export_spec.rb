RSpec.describe ROM::LDAP::Relation, 'exporting' do

  include_context 'people'

  before do
    %w[Peter Leanda].each.with_index(123) do |gn, i|
      factories[:person, given_name: gn, uid_number: i, sn: 'Hamilton']
    end
  end

  # after do
  #   people.where(sn: 'Hamilton').delete
  # end

  # Attributes are in the order selected (alphabetical)
  #
  let(:attrs) do
    %i[cn dn given_name object_class sn uid_number]
  end

  context 'a single tuple' do
    let(:relation) { people.where(given_name: 'leanda').project(*attrs) }

    it '#to_msgpack' do
      export = {
        "cn"          => ["Leanda Hamilton"],
        "dn"          => ["cn=Leanda Hamilton,ou=specs,dc=example,dc=com"],
        "givenName"   => ["Leanda"],
        "objectClass" => ["apple-user", "organizationalPerson", "person", "extensibleObject", "inetOrgPerson", "top"],
        "sn"          => ["Hamilton"],
        "uidNumber"   => ["124"]
      }

      expect(MessagePack.unpack(relation.to_msgpack)).to eql(export)
    end

    it '#to_ldif' do
      export = <<~LDIF
      cn: Leanda Hamilton
      dn: cn=Leanda Hamilton,ou=specs,dc=example,dc=com
      givenName: Leanda
      objectClass: apple-user
      objectClass: organizationalPerson
      objectClass: person
      objectClass: extensibleObject
      objectClass: inetOrgPerson
      objectClass: top
      sn: Hamilton
      uidNumber: 124

      LDIF

      expect(relation.to_ldif).to eql(export)
    end

    it '#to_json' do
      export = '{"cn":["Leanda Hamilton"],"dn":["cn=Leanda Hamilton,ou=specs,dc=example,dc=com"],"givenName":["Leanda"],"objectClass":["apple-user","organizationalPerson","person","extensibleObject","inetOrgPerson","top"],"sn":["Hamilton"],"uidNumber":["124"]}'

      expect(relation.to_json).to eql(export)
    end

    it '#to_yaml' do
      export = <<~YAML
      ---
      cn:
      - Leanda Hamilton
      dn:
      - cn=Leanda Hamilton,ou=specs,dc=example,dc=com
      givenName:
      - Leanda
      objectClass:
      - apple-user
      - organizationalPerson
      - person
      - extensibleObject
      - inetOrgPerson
      - top
      sn:
      - Hamilton
      uidNumber:
      - '124'
      YAML

      expect(relation.to_yaml).to eql(export)
    end

  end




  context 'multiple tuples' do

    let(:relation) { people.where(sn: 'Hamilton').project(*attrs) }

    it '#to_msgpack' do
      export = [
        {
          "cn"          => ["Leanda Hamilton"],
          "dn"          => ["cn=Leanda Hamilton,ou=specs,dc=example,dc=com"],
          "givenName"   => ["Leanda"],
          "objectClass" => ["apple-user", "organizationalPerson", "person", "extensibleObject", "inetOrgPerson", "top"],
          "sn"          => ["Hamilton"],
          "uidNumber"   => ["124"]
        },
        {
          "cn"          => ["Peter Hamilton"],
          "dn"          => ["cn=Peter Hamilton,ou=specs,dc=example,dc=com"],
          "givenName"   => ["Peter"],
          "objectClass" => ["apple-user", "organizationalPerson", "person", "extensibleObject", "inetOrgPerson", "top"],
          "sn"          => ["Hamilton"],
          "uidNumber"   => ["123"]
        }
      ]

      expect(MessagePack.unpack(relation.to_msgpack)).to eql(export)
    end

    it '#to_ldif' do
      export = <<~LDIF
      cn: Leanda Hamilton
      dn: cn=Leanda Hamilton,ou=specs,dc=example,dc=com
      givenName: Leanda
      objectClass: apple-user
      objectClass: organizationalPerson
      objectClass: person
      objectClass: extensibleObject
      objectClass: inetOrgPerson
      objectClass: top
      sn: Hamilton
      uidNumber: 124

      cn: Peter Hamilton
      dn: cn=Peter Hamilton,ou=specs,dc=example,dc=com
      givenName: Peter
      objectClass: apple-user
      objectClass: organizationalPerson
      objectClass: person
      objectClass: extensibleObject
      objectClass: inetOrgPerson
      objectClass: top
      sn: Hamilton
      uidNumber: 123

      LDIF

      expect(relation.to_ldif).to eql(export)
    end

    it '#to_json' do
      export = '[{"cn":["Leanda Hamilton"],"dn":["cn=Leanda Hamilton,ou=specs,dc=example,dc=com"],"givenName":["Leanda"],"objectClass":["apple-user","organizationalPerson","person","extensibleObject","inetOrgPerson","top"],"sn":["Hamilton"],"uidNumber":["124"]},{"cn":["Peter Hamilton"],"dn":["cn=Peter Hamilton,ou=specs,dc=example,dc=com"],"givenName":["Peter"],"objectClass":["apple-user","organizationalPerson","person","extensibleObject","inetOrgPerson","top"],"sn":["Hamilton"],"uidNumber":["123"]}]'

      expect(relation.to_json).to eql(export)
    end

    it '#to_yaml' do
      export = <<~YAML
      ---
      - cn:
        - Leanda Hamilton
        dn:
        - cn=Leanda Hamilton,ou=specs,dc=example,dc=com
        givenName:
        - Leanda
        objectClass:
        - apple-user
        - organizationalPerson
        - person
        - extensibleObject
        - inetOrgPerson
        - top
        sn:
        - Hamilton
        uidNumber:
        - '124'
      - cn:
        - Peter Hamilton
        dn:
        - cn=Peter Hamilton,ou=specs,dc=example,dc=com
        givenName:
        - Peter
        objectClass:
        - apple-user
        - organizationalPerson
        - person
        - extensibleObject
        - inetOrgPerson
        - top
        sn:
        - Hamilton
        uidNumber:
        - '123'
      YAML

      expect(relation.to_yaml).to eql(export)
    end

  end
end
