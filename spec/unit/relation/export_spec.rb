require 'rom/ldap/extensions/exporters/dsml'
require 'rom/ldap/extensions/exporters/msgpack'

RSpec.describe ROM::LDAP::Relation, 'exporting' do

  include_context 'people'

  before do
    %w[Peter Leanda].each.with_index(123) do |gn, i|
      factories[:person, given_name: gn, uid_number: i, sn: 'Hamilton']
    end
  end

  after do
    people.delete
  end

  let(:attrs) { %i[uid_number cn object_class sn given_name] }


  # it 'raises error when the Dataset has been enumerated' do
  #   expect {
  #     binding.pry
  #     people.random.to_ldif
  #   }.to raise_error('The dataset is no longer a Dataset class')
  # end

  context 'with a single tuple' do

    let(:relation) { people.where(given_name: 'leanda').project(*attrs) }

    it '#to_msgpack' do
      output = {
        "dn"          => ["cn=Leanda Hamilton,ou=specs,dc=rom,dc=ldap"],
        "cn"          => ["Leanda Hamilton"],
        "givenName"   => ["Leanda"],
        "objectClass" => ["top", "inetOrgPerson", "person", "organizationalPerson", "extensibleObject"],
        "sn"          => ["Hamilton"],
        "uidNumber"   => ["124"]
      }

      expect(MessagePack.unpack(relation.to_msgpack)).to eql(output)
    end

    it '#to_ldif' do
      output = <<~LDIF
        dn: cn=Leanda Hamilton,ou=specs,dc=rom,dc=ldap
        cn: Leanda Hamilton
        givenName: Leanda
        objectClass: top
        objectClass: inetOrgPerson
        objectClass: person
        objectClass: organizationalPerson
        objectClass: extensibleObject
        sn: Hamilton
        uidNumber: 124

        LDIF

      expect(relation.to_ldif).to eql(output)
    end

    it '#to_json' do
      output = '{"dn":["cn=Leanda Hamilton,ou=specs,dc=rom,dc=ldap"],"cn":["Leanda Hamilton"],"givenName":["Leanda"],"objectClass":["top","inetOrgPerson","person","organizationalPerson","extensibleObject"],"sn":["Hamilton"],"uidNumber":["124"]}'

      # output = <<~JSON
      #   {
      #     "dn": ["cn=Leanda Hamilton,ou=specs,dc=rom,dc=ldap"],
      #     "cn": ["Leanda Hamilton"],
      #     "givenName": ["Leanda"],
      #     "objectClass": [
      #       "top",
      #       "inetOrgPerson",
      #       "person",
      #       "organizationalPerson",
      #       "extensibleObject"
      #     ],
      #     "sn": ["Hamilton"],
      #     "uidNumber": ["124"]
      #   }
      #   JSON

      expect(relation.to_json).to eql(output)
    end

    it '#to_yaml' do
      output = <<~YAML
        ---
        dn:
        - cn=Leanda Hamilton,ou=specs,dc=rom,dc=ldap
        cn:
        - Leanda Hamilton
        givenName:
        - Leanda
        objectClass:
        - top
        - inetOrgPerson
        - person
        - organizationalPerson
        - extensibleObject
        sn:
        - Hamilton
        uidNumber:
        - '124'
        YAML

      expect(relation.to_yaml).to eql(output)
    end

    it '#to_dsml' do
      output = <<~DSML
        <?xml version="1.0" encoding="UTF-8"?>
        <dsml>
          <directory-entries>
            <entry dn="cn=Leanda Hamilton,ou=specs,dc=rom,dc=ldap">
              <objectclass>
                <oc-value>top</oc-value>
                <oc-value>inetOrgPerson</oc-value>
                <oc-value>person</oc-value>
                <oc-value>organizationalPerson</oc-value>
                <oc-value>extensibleObject</oc-value>
              </objectclass>
              <attr name="cn">
                <value>Leanda Hamilton</value>
              </attr>
              <attr name="givenName">
                <value>Leanda</value>
              </attr>
              <attr name="sn">
                <value>Hamilton</value>
              </attr>
              <attr name="uidNumber">
                <value>124</value>
              </attr>
            </entry>
          </directory-entries>
        </dsml>
        DSML

      expect(relation.to_dsml).to eql(output)
    end
  end




  context 'with multiple tuples' do

    let(:relation) { people.where(sn: 'Hamilton').order(:uid_number).project(*attrs) }

    it '#to_msgpack' do
      output = [
        {
          "dn"          => ["cn=Peter Hamilton,ou=specs,dc=rom,dc=ldap"],
          "cn"          => ["Peter Hamilton"],
          "givenName"   => ["Peter"],
          "objectClass" => ["top", "inetOrgPerson", "person", "organizationalPerson", "extensibleObject"],
          "sn"          => ["Hamilton"],
          "uidNumber"   => ["123"]
        },
        {
          "dn"          => ["cn=Leanda Hamilton,ou=specs,dc=rom,dc=ldap"],
          "cn"          => ["Leanda Hamilton"],
          "givenName"   => ["Leanda"],
          "objectClass" => ["top", "inetOrgPerson", "person", "organizationalPerson", "extensibleObject"],
          "sn"          => ["Hamilton"],
          "uidNumber"   => ["124"]
        }
      ]

      expect(MessagePack.unpack(relation.to_msgpack)).to eql(output)
    end

    it '#to_ldif' do
      output = <<~LDIF
        dn: cn=Peter Hamilton,ou=specs,dc=rom,dc=ldap
        cn: Peter Hamilton
        givenName: Peter
        objectClass: top
        objectClass: inetOrgPerson
        objectClass: person
        objectClass: organizationalPerson
        objectClass: extensibleObject
        sn: Hamilton
        uidNumber: 123


        dn: cn=Leanda Hamilton,ou=specs,dc=rom,dc=ldap
        cn: Leanda Hamilton
        givenName: Leanda
        objectClass: top
        objectClass: inetOrgPerson
        objectClass: person
        objectClass: organizationalPerson
        objectClass: extensibleObject
        sn: Hamilton
        uidNumber: 124

        LDIF

      expect(relation.to_ldif).to eql(output)
    end

    it '#to_json' do
      output = '[{"dn":["cn=Peter Hamilton,ou=specs,dc=rom,dc=ldap"],"cn":["Peter Hamilton"],"givenName":["Peter"],"objectClass":["top","inetOrgPerson","person","organizationalPerson","extensibleObject"],"sn":["Hamilton"],"uidNumber":["123"]},{"dn":["cn=Leanda Hamilton,ou=specs,dc=rom,dc=ldap"],"cn":["Leanda Hamilton"],"givenName":["Leanda"],"objectClass":["top","inetOrgPerson","person","organizationalPerson","extensibleObject"],"sn":["Hamilton"],"uidNumber":["124"]}]'

      expect(relation.to_json).to eql(output)
    end

    it '#to_yaml' do
      output = <<~YAML
        ---
        - dn:
          - cn=Peter Hamilton,ou=specs,dc=rom,dc=ldap
          cn:
          - Peter Hamilton
          givenName:
          - Peter
          objectClass:
          - top
          - inetOrgPerson
          - person
          - organizationalPerson
          - extensibleObject
          sn:
          - Hamilton
          uidNumber:
          - '123'
        - dn:
          - cn=Leanda Hamilton,ou=specs,dc=rom,dc=ldap
          cn:
          - Leanda Hamilton
          givenName:
          - Leanda
          objectClass:
          - top
          - inetOrgPerson
          - person
          - organizationalPerson
          - extensibleObject
          sn:
          - Hamilton
          uidNumber:
          - '124'
        YAML

      expect(relation.to_yaml).to eql(output)
    end

    it '#to_dsml' do
      output = <<~DSML
        <?xml version="1.0" encoding="UTF-8"?>
        <dsml>
          <directory-entries>
            <entry dn="cn=Peter Hamilton,ou=specs,dc=rom,dc=ldap">
              <objectclass>
                <oc-value>top</oc-value>
                <oc-value>inetOrgPerson</oc-value>
                <oc-value>person</oc-value>
                <oc-value>organizationalPerson</oc-value>
                <oc-value>extensibleObject</oc-value>
              </objectclass>
              <attr name="cn">
                <value>Peter Hamilton</value>
              </attr>
              <attr name="givenName">
                <value>Peter</value>
              </attr>
              <attr name="sn">
                <value>Hamilton</value>
              </attr>
              <attr name="uidNumber">
                <value>123</value>
              </attr>
            </entry>
            <entry dn="cn=Leanda Hamilton,ou=specs,dc=rom,dc=ldap">
              <objectclass>
                <oc-value>top</oc-value>
                <oc-value>inetOrgPerson</oc-value>
                <oc-value>person</oc-value>
                <oc-value>organizationalPerson</oc-value>
                <oc-value>extensibleObject</oc-value>
              </objectclass>
              <attr name="cn">
                <value>Leanda Hamilton</value>
              </attr>
              <attr name="givenName">
                <value>Leanda</value>
              </attr>
              <attr name="sn">
                <value>Hamilton</value>
              </attr>
              <attr name="uidNumber">
                <value>124</value>
              </attr>
            </entry>
          </directory-entries>
        </dsml>
        DSML

      expect(relation.to_dsml).to eql(output)
    end
  end
end
