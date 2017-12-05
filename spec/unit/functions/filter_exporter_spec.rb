RSpec.describe ROM::LDAP::Functions::FilterExporter do

  let(:exporter) { ROM::LDAP::Functions::FilterExporter.new }

  it '(&(|(cn~=John)(sn=Smith))(!(uid=*)))' do
    ast = exporter.call(
      [
        :con_and,
        [
          [
            :con_or,
            [
              [:op_prx, 'cn', 'John'],
              [:op_eql, 'sn', 'Smith']
            ]
          ],
          [
            :con_not,
            [:op_eql, 'uid', :wildcard]
          ]
        ]
      ]
    )

    expect(ast).to eql('(&(|(cn~=John)(sn=Smith))(!(uid=*)))')
  end

  it '(&(gn~=Peter)(sn=Hamilton))' do

    ast = exporter.call(
      [
        :con_and,
        [
          [:op_prx, 'gn', 'Peter'],
          [:op_eql, 'sn', 'Hamilton'],
        ]
      ]
    )

    expect(ast).to eql('(&(gn~=Peter)(sn=Hamilton))')
  end

  it '(!(gn~=Peter))' do
    ast = exporter.call([ :con_not, [:op_prx, 'gn', 'Peter'] ])
    expect(ast).to eql('(!(gn~=Peter))')
  end

  it '(|(mail=*)(uid>=500)(cn~=Peter Hamilton))' do

    ast = exporter.call(
      [
        :con_or,
        [
          [:op_prx, 'cn', 'Peter Hamilton'],
          [:op_eql, 'mail', :wildcard],
          [:op_gte, 'uid', 500],
        ]
      ]
    )

    expect(ast).to eql('(|(cn~=Peter Hamilton)(mail=*)(uid>=500))')
  end

  describe 'single expressions' do
    it 'approximately' do
      ast = exporter.call([:op_prx, 'cn', 'Peter Hamilton'])
      expect(ast).to eql('(cn~=Peter Hamilton)')
    end

    it 'equals' do
      ast = exporter.call([:op_eql, 'mail', '*@peterdavidhamilton.com'])
      expect(ast).to eql('(mail=*@peterdavidhamilton.com)')
    end

    it 'greater than' do
      ast = exporter.call([:op_gte, 'uid', 500])
      expect(ast).to eql('(uid>=500)')
    end


    it 'less than or equal' do
      ast = exporter.call([:op_lte, 'uid', 500])
      expect(ast).to eql('(uid<=500)')
    end
  end

end
