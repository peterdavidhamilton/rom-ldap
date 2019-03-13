require 'rom/ldap/extensions/exporters/dsml'


RSpec.describe ROM::LDAP::DSML, '#to_dsml' do

  context 'with refinement' do
    using ROM::LDAP::DSML

    describe 'Hash' do
      it 'returns a single entry in DSML format' do

        entry = {
          'dn' => %w'cn=foo,dc=rom,dc=ldap',
          'objectClass' => %w'top person inetOrgPerson',
          'multi' => %w'foo bar baz',
          'givenName' => %w'foo'
        }

        output = <<~EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <dsml>
            <directory-entries>
              <entry dn="cn=foo,dc=rom,dc=ldap">
                <objectclass>
                  <oc-value>top</oc-value>
                  <oc-value>person</oc-value>
                  <oc-value>inetOrgPerson</oc-value>
                </objectclass>
                <attr name="multi">
                  <value>foo</value>
                  <value>bar</value>
                  <value>baz</value>
                </attr>
                <attr name="givenName">
                  <value>foo</value>
                </attr>
              </entry>
            </directory-entries>
          </dsml>
          EOF

        expect(entry.to_dsml).to eq(output)
      end

      it 'values must respond to each' do
        expect { { 'cn' => 'baz' }.to_dsml }.to raise_error(NoMethodError, /each/)
      end
    end

    describe 'Array' do
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
            'dn' => ['cn=leanda,dc=rom,dc=ldap'],
            'objectClass' => ['person', 'inetOrgPerson'],
            'multi' => %w'foo bar baz',
            'cn' => ['leanda christine hamilton'],
            'givenName' => ['leanda']
          },
          {
            'dn' => ['cn=peter,dc=rom,dc=ldap'],
            'objectClass' => ['person', 'inetOrgPerson'],
            'cn' => ['peter david hamilton'],
            'givenName' => ['peter']
          }
        ]

        output = <<~EOF
          <?xml version="1.0" encoding="UTF-8"?>
          <dsml>
            <directory-entries>
              <entry dn="cn=leanda,dc=rom,dc=ldap">
                <objectclass>
                  <oc-value>person</oc-value>
                  <oc-value>inetOrgPerson</oc-value>
                </objectclass>
                <attr name="multi">
                  <value>foo</value>
                  <value>bar</value>
                  <value>baz</value>
                </attr>
                <attr name="cn">
                  <value>leanda christine hamilton</value>
                </attr>
                <attr name="givenName">
                  <value>leanda</value>
                </attr>
              </entry>
              <entry dn="cn=peter,dc=rom,dc=ldap">
                <objectclass>
                  <oc-value>person</oc-value>
                  <oc-value>inetOrgPerson</oc-value>
                </objectclass>
                <attr name="cn">
                  <value>peter david hamilton</value>
                </attr>
                <attr name="givenName">
                  <value>peter</value>
                </attr>
              </entry>
            </directory-entries>
          </dsml>
          EOF

        expect(entries.to_dsml).to eq(output)

      end
    end
  end


  context 'without refinement' do
    describe 'Hash' do
      it 'raises an exception' do
        expect { Hash.new.to_dsml }.to raise_error(NoMethodError)
      end
    end

    describe 'Array' do
      it 'raises an exception' do
        expect { Array.new.to_dsml }.to raise_error(NoMethodError)
      end
    end
  end

end
