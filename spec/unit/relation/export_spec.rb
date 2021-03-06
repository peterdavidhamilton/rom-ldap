require 'rom/ldap/extensions/dsml'
require 'rom/ldap/extensions/msgpack'
require 'rom/ldap/extensions/optimised_json'


RSpec.describe ROM::LDAP::Relation, 'exporting' do

  include_context 'people'

  # NB: OpenLDAP classes are only "inetOrgPerson", "extensibleObject"
  # NB: OpenDJ abd 389DS classes are in a different order

  with_vendors do

    before do
      factories[:person,  uid_number: 123, given_name: 'Scott', sn: 'Summers']
      factories[:person,  uid_number: 124, given_name: 'Alex', sn: 'Summers']
    end

    let(:attrs) { %i[uid_number cn sn given_name] }

    context 'with a single tuple' do

      let(:relation) { people.where(given_name: 'Alex').project(*attrs) }

      it '#to_msgpack' do
        output = {
          "dn"          => ["cn=Alex Summers,ou=specs,dc=rom,dc=ldap"],
          "cn"          => ["Alex Summers"],
          "givenName"   => ["Alex"],
          "sn"          => ["Summers"],
          "uidNumber"   => ["124"]
        }

        expect(MessagePack.unpack(relation.to_msgpack)).to eql(output)
      end

      it '#to_ldif' do
        output = <<~LDIF
          dn: cn=Alex Summers,ou=specs,dc=rom,dc=ldap
          cn: Alex Summers
          givenName: Alex
          sn: Summers
          uidNumber: 124

          LDIF

        expect(relation.to_ldif).to eql(output)
      end

      it '#to_json' do
        output = '{"dn":["cn=Alex Summers,ou=specs,dc=rom,dc=ldap"],"cn":["Alex Summers"],"givenName":["Alex"],"sn":["Summers"],"uidNumber":["124"]}'

        expect(relation.to_json).to eql(output)
      end

      it '#to_yaml' do
        output = <<~YAML
          ---
          dn:
          - cn=Alex Summers,ou=specs,dc=rom,dc=ldap
          cn:
          - Alex Summers
          givenName:
          - Alex
          sn:
          - Summers
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
              <entry dn="cn=Alex Summers,ou=specs,dc=rom,dc=ldap">
                <objectclass/>
                <attr name="cn">
                  <value>Alex Summers</value>
                </attr>
                <attr name="givenName">
                  <value>Alex</value>
                </attr>
                <attr name="sn">
                  <value>Summers</value>
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

      let(:relation) { people.where(sn: 'Summers').order(:uid_number).project(*attrs) }

      it '#to_msgpack' do
        output = [
          {
            "dn"          => ["cn=Scott Summers,ou=specs,dc=rom,dc=ldap"],
            "cn"          => ["Scott Summers"],
            "givenName"   => ["Scott"],
            "sn"          => ["Summers"],
            "uidNumber"   => ["123"]
          },
          {
            "dn"          => ["cn=Alex Summers,ou=specs,dc=rom,dc=ldap"],
            "cn"          => ["Alex Summers"],
            "givenName"   => ["Alex"],
            "sn"          => ["Summers"],
            "uidNumber"   => ["124"]
          }
        ]

        expect(MessagePack.unpack(relation.to_msgpack)).to eql(output)
      end

      it '#to_ldif' do
        output = <<~LDIF
          dn: cn=Scott Summers,ou=specs,dc=rom,dc=ldap
          cn: Scott Summers
          givenName: Scott
          sn: Summers
          uidNumber: 123


          dn: cn=Alex Summers,ou=specs,dc=rom,dc=ldap
          cn: Alex Summers
          givenName: Alex
          sn: Summers
          uidNumber: 124

          LDIF

        expect(relation.to_ldif).to eql(output)
      end

      it '#to_json' do
        output = '[{"dn":["cn=Scott Summers,ou=specs,dc=rom,dc=ldap"],"cn":["Scott Summers"],"givenName":["Scott"],"sn":["Summers"],"uidNumber":["123"]},{"dn":["cn=Alex Summers,ou=specs,dc=rom,dc=ldap"],"cn":["Alex Summers"],"givenName":["Alex"],"sn":["Summers"],"uidNumber":["124"]}]'

        expect(relation.to_json).to eql(output)
      end

      it '#to_yaml' do
        output = <<~YAML
          ---
          - dn:
            - cn=Scott Summers,ou=specs,dc=rom,dc=ldap
            cn:
            - Scott Summers
            givenName:
            - Scott
            sn:
            - Summers
            uidNumber:
            - '123'
          - dn:
            - cn=Alex Summers,ou=specs,dc=rom,dc=ldap
            cn:
            - Alex Summers
            givenName:
            - Alex
            sn:
            - Summers
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
              <entry dn="cn=Scott Summers,ou=specs,dc=rom,dc=ldap">
                <objectclass/>
                <attr name="cn">
                  <value>Scott Summers</value>
                </attr>
                <attr name="givenName">
                  <value>Scott</value>
                </attr>
                <attr name="sn">
                  <value>Summers</value>
                </attr>
                <attr name="uidNumber">
                  <value>123</value>
                </attr>
              </entry>
              <entry dn="cn=Alex Summers,ou=specs,dc=rom,dc=ldap">
                <objectclass/>
                <attr name="cn">
                  <value>Alex Summers</value>
                </attr>
                <attr name="givenName">
                  <value>Alex</value>
                </attr>
                <attr name="sn">
                  <value>Summers</value>
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
end
