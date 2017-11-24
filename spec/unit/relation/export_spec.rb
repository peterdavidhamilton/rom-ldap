require 'spec_helper'

RSpec.describe ROM::LDAP::Relation do

  describe 'exports formats' do

    let(:formatter) { method_name_proc }
    include_context 'relations'

    let(:relation) do
      accounts.where(uid: 'test1').pluck(
        :dn, :mail, :given_name, :sn, :cn, :object_class,
        :gid_number, :uid_number, :user_password, :uid)
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

      LDIF

      expect(relation.to_ldif).to eql(export)
    end

    it '#to_json' do
      export = '[{"dn":["uid=test1,ou=users,dc=example,dc=com"],"mail":["test1@example.com"],"givenName":["test1"],"sn":["test1"],"cn":["test1"],"objectClass":["top","inetOrgPerson","person","organizationalPerson","extensibleObject"],"gidNumber":["9998"],"uidNumber":["1"],"userPassword":["{SHA}tESsBmE/yNY3lb6a0L6vVQEZNqw="],"uid":["test1"]}]'
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
      YAML

      expect(relation.to_yaml).to eql(export)
    end

  end
end
