require 'msgpack'

RSpec.describe ROM::LDAP::Relation do

  describe 'exports single tuple to different formats' do

    let(:formatter) { method_name_proc }
    include_context 'relations'

    # Attributes are in the order selected (alphabetical)
    #
    let(:relation) do
      attributes = %i[cn dn gid_number given_name mail object_class sn uid uid_number user_password]
      accounts.select(*attributes).where(uid: 'test1')
    end

    it '#to_msgpack' do
      export = {
        "cn"            => ["test1"],
        "dn"            => ["uid=test1,ou=users,dc=example,dc=com"],
        "gidNumber"     => ["9998"],
        "givenName"     => ["test1"],
        "mail"          => ["test1@example.com"],
        "objectClass"   => ["top", "inetOrgPerson", "person", "organizationalPerson", "extensibleObject"],
        "sn"            => ["test1"],
        "uid"           => ["test1"],
        "uidNumber"     => ["1"],
        "userPassword"  => ["{SHA}tESsBmE/yNY3lb6a0L6vVQEZNqw="]
      }

      expect(MessagePack.unpack(relation.to_msgpack)).to eql(export)
    end

    it '#to_ldif' do
      export = <<~LDIF
      cn: test1
      dn: uid=test1,ou=users,dc=example,dc=com
      gidNumber: 9998
      givenName: test1
      mail: test1@example.com
      objectClass: top
      objectClass: inetOrgPerson
      objectClass: person
      objectClass: organizationalPerson
      objectClass: extensibleObject
      sn: test1
      uid: test1
      uidNumber: 1
      userPassword: {SHA}tESsBmE/yNY3lb6a0L6vVQEZNqw=

      LDIF

      expect(relation.to_ldif).to eql(export)
    end

    it '#to_json' do
      export = <<~JSON
        {
          "cn": [
              "test1"
          ],
          "dn": [
              "uid=test1,ou=users,dc=example,dc=com"
          ],
          "gidNumber": [
              "9998"
          ],
          "givenName": [
              "test1"
          ],
          "mail": [
              "test1@example.com"
          ],
          "objectClass": [
              "top",
              "inetOrgPerson",
              "person",
              "organizationalPerson",
              "extensibleObject"
          ],
          "sn": [
              "test1"
          ],
          "uid": [
              "test1"
          ],
          "uidNumber": [
              "1"
          ],
          "userPassword": [
              "{SHA}tESsBmE/yNY3lb6a0L6vVQEZNqw="
          ]
        }
      JSON
      .delete(" \n")

      expect(relation.to_json).to eql(export)
    end

    it '#to_yaml' do
      export = <<~YAML
      ---
      cn:
      - test1
      dn:
      - uid=test1,ou=users,dc=example,dc=com
      gidNumber:
      - '9998'
      givenName:
      - test1
      mail:
      - test1@example.com
      objectClass:
      - top
      - inetOrgPerson
      - person
      - organizationalPerson
      - extensibleObject
      sn:
      - test1
      uid:
      - test1
      uidNumber:
      - '1'
      userPassword:
      - "{SHA}tESsBmE/yNY3lb6a0L6vVQEZNqw="
      YAML

      expect(relation.to_yaml).to eql(export)
    end

  end




  describe 'exports multiple tuples to different formats' do

    let(:formatter) { method_name_proc }
    include_context 'relations'

    let(:relation) do
      accounts.where(uid: ['test1','test2']).pluck(
        :dn, :mail, :given_name, :sn, :cn, :object_class,
        :gid_number, :uid_number, :user_password, :uid)
    end

    it '#to_msgpack' do
      export = [
        {
          "dn"            => ["uid=test1,ou=users,dc=example,dc=com"],
          "mail"          => ["test1@example.com"],
          "givenName"     => ["test1"],
          "sn"            => ["test1"],
          "cn"            => ["test1"],
          "objectClass"   => ["top", "inetOrgPerson", "person", "organizationalPerson", "extensibleObject"],
          "gidNumber"     => ["9998"],
          "uidNumber"     => ["1"],
          "userPassword"  => ["{SHA}tESsBmE/yNY3lb6a0L6vVQEZNqw="],
          "uid"           => ["test1"]
        },
        {
          "dn"            => ["uid=test2,ou=users,dc=example,dc=com"],
          "mail"          => ["test2@example.com"],
          "givenName"     => ["test2"],
          "sn"            => ["test2"],
          "cn"            => ["test2"],
          "objectClass"   => ["top", "inetOrgPerson", "person", "organizationalPerson", "extensibleObject"],
          "gidNumber"     => ["9998"],
          "uidNumber"     => ["2"],
          "userPassword"  => ["{SHA}EJ9LPFDXsN9ynSmbxvjp75Bmlx8="],
          "uid"           => ["test2"]
        }
      ]

      expect(MessagePack.unpack(relation.to_msgpack)).to eql(export)
    end

    it '#to_ldif' do
      export = <<~LDIF
      dn: uid=test1,ou=users,dc=example,dc=com
      mail: test1@example.com
      givenName: test1
      sn: test1
      cn: test1
      objectClass: top
      objectClass: inetOrgPerson
      objectClass: person
      objectClass: organizationalPerson
      objectClass: extensibleObject
      gidNumber: 9998
      uidNumber: 1
      userPassword: {SHA}tESsBmE/yNY3lb6a0L6vVQEZNqw=
      uid: test1

      dn: uid=test2,ou=users,dc=example,dc=com
      mail: test2@example.com
      givenName: test2
      sn: test2
      cn: test2
      objectClass: top
      objectClass: inetOrgPerson
      objectClass: person
      objectClass: organizationalPerson
      objectClass: extensibleObject
      gidNumber: 9998
      uidNumber: 2
      userPassword: {SHA}EJ9LPFDXsN9ynSmbxvjp75Bmlx8=
      uid: test2

      LDIF

      expect(relation.to_ldif).to eql(export)
    end

    it '#to_json' do
      export = '[{"dn":["uid=test1,ou=users,dc=example,dc=com"],"mail":["test1@example.com"],"givenName":["test1"],"sn":["test1"],"cn":["test1"],"objectClass":["top","inetOrgPerson","person","organizationalPerson","extensibleObject"],"gidNumber":["9998"],"uidNumber":["1"],"userPassword":["{SHA}tESsBmE/yNY3lb6a0L6vVQEZNqw="],"uid":["test1"]},{"dn":["uid=test2,ou=users,dc=example,dc=com"],"mail":["test2@example.com"],"givenName":["test2"],"sn":["test2"],"cn":["test2"],"objectClass":["top","inetOrgPerson","person","organizationalPerson","extensibleObject"],"gidNumber":["9998"],"uidNumber":["2"],"userPassword":["{SHA}EJ9LPFDXsN9ynSmbxvjp75Bmlx8="],"uid":["test2"]}]'
      expect(relation.to_json).to eql(export)
    end

    it '#to_yaml' do
      export = <<~YAML
      ---
      - dn:
        - uid=test1,ou=users,dc=example,dc=com
        mail:
        - test1@example.com
        givenName:
        - test1
        sn:
        - test1
        cn:
        - test1
        objectClass:
        - top
        - inetOrgPerson
        - person
        - organizationalPerson
        - extensibleObject
        gidNumber:
        - '9998'
        uidNumber:
        - '1'
        userPassword:
        - "{SHA}tESsBmE/yNY3lb6a0L6vVQEZNqw="
        uid:
        - test1
      - dn:
        - uid=test2,ou=users,dc=example,dc=com
        mail:
        - test2@example.com
        givenName:
        - test2
        sn:
        - test2
        cn:
        - test2
        objectClass:
        - top
        - inetOrgPerson
        - person
        - organizationalPerson
        - extensibleObject
        gidNumber:
        - '9998'
        uidNumber:
        - '2'
        userPassword:
        - "{SHA}EJ9LPFDXsN9ynSmbxvjp75Bmlx8="
        uid:
        - test2
      YAML

      expect(relation.to_yaml).to eql(export)
    end

  end
end
