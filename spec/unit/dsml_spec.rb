require 'rom/ldap/extensions/dsml'

RSpec.describe ROM::LDAP::DSML do

  context 'using refinement' do
    using ROM::LDAP::DSML

    describe ::Hash, '#to_dsml' do
      it 'returns a single entry in DSML format' do

        entry = {
          'dn' => %w'cn=Magneto,dc=rom,dc=ldap',
          'objectClass' => %w'top person inetOrgPerson',
          'powers' => %w'Magnetokinesis Ferrokinesis',
          'givenName' => %w'Erik'
        }

        output = <<~EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <dsml>
            <directory-entries>
              <entry dn="cn=Magneto,dc=rom,dc=ldap">
                <objectclass>
                  <oc-value>top</oc-value>
                  <oc-value>person</oc-value>
                  <oc-value>inetOrgPerson</oc-value>
                </objectclass>
                <attr name="powers">
                  <value>Magnetokinesis</value>
                  <value>Ferrokinesis</value>
                </attr>
                <attr name="givenName">
                  <value>Erik</value>
                </attr>
              </entry>
            </directory-entries>
          </dsml>
          EOF

        expect(entry.to_dsml).to eq(output)
      end

      it 'values must respond to each' do
        expect { { 'cn' => 'Magneto' }.to_dsml }.to raise_error(NoMethodError, /each/)
      end
    end

    describe ::Array, '#to_dsml' do
      it 'returns multiple entries in DSML format' do

        output = <<~EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <dsml>
            <directory-entries/>
          </dsml>
          EOF

        expect( [].to_dsml ).to eq(output)
        expect( [{}].to_dsml ).to eq(output)


        entries = [
          {
            'dn' => ['cn=Wanda,dc=rom,dc=ldap'],
            'objectClass' => ['person', 'inetOrgPerson'],
            'powers' => %w'Telekinesis Telepathy Hypnosis',
            'cn' => ['Wanda Maximoff'],
            'givenName' => ['Wanda']
          },
          {
            'dn' => ['cn=Pietro,dc=rom,dc=ldap'],
            'objectClass' => ['person', 'inetOrgPerson'],
            'cn' => ['Pietro Maximoff'],
            'givenName' => ['Pietro']
          }
        ]

        output = <<~EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <dsml>
            <directory-entries>
              <entry dn="cn=Wanda,dc=rom,dc=ldap">
                <objectclass>
                  <oc-value>person</oc-value>
                  <oc-value>inetOrgPerson</oc-value>
                </objectclass>
                <attr name="powers">
                  <value>Telekinesis</value>
                  <value>Telepathy</value>
                  <value>Hypnosis</value>
                </attr>
                <attr name="cn">
                  <value>Wanda Maximoff</value>
                </attr>
                <attr name="givenName">
                  <value>Wanda</value>
                </attr>
              </entry>
              <entry dn="cn=Pietro,dc=rom,dc=ldap">
                <objectclass>
                  <oc-value>person</oc-value>
                  <oc-value>inetOrgPerson</oc-value>
                </objectclass>
                <attr name="cn">
                  <value>Pietro Maximoff</value>
                </attr>
                <attr name="givenName">
                  <value>Pietro</value>
                </attr>
              </entry>
            </directory-entries>
          </dsml>
          EOF

        expect(entries.to_dsml).to eq(output)

      end
    end
  end


  context 'not using refinement' do
    describe ::Hash, '#to_dsml' do
      specify { expect(described_class.new).to_not respond_to(:to_dsml) }
      specify { expect { described_class.new.to_dsml }.to raise_error(NoMethodError) }
    end

    describe ::Array, '#to_dsml' do
      specify { expect(described_class.new).to_not respond_to(:to_dsml) }
      specify { expect { described_class.new.to_dsml }.to raise_error(NoMethodError) }
    end
  end

end
