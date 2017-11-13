require 'spec_helper'

require 'rom/ldap/filter/decomposer'

RSpec.describe ROM::LDAP::Filter::Decomposer do

  let(:decomposer) { ROM::LDAP::Filter::Decomposer.new }

  # it '(&(|(cn~=John)(sn=Smith))(!(uid=*)))' do

  #   ast = decomposer.call(
  #     [
  #       :con_and,
  #       [
  #         [:con_or,  [[:op_prox, 'cn', 'John'], [:op_equal, 'sn', 'Smith']]],
  #         [:con_not, [:op_equal, 'uid', :wildcard]]
  #       ]
  #     ]
  #   )

  #   expect(ast).to eql('(&(|(cn~=John)(sn=Smith))(!(uid=*)))')
  # end


  it '(&((gn~=Peter)(sn=Hamilton)))' do

    ast = decomposer.call(
      [
        :con_and,
        [
          [:op_prox, 'gn', 'Peter'],
          [:op_equal, 'sn', 'Hamilton'],
        ]
      ]
    )

    expect(ast).to eql('(&((gn~=Peter)(sn=Hamilton)))')
  end

  it '(|((mail=*)(uid>=500)(cn~=Peter Hamilton)))' do

    ast = decomposer.call(
      [
        :con_or,
        [
          [:op_prox, 'cn', 'Peter Hamilton'],
          [:op_equal, 'mail', :wildcard],
          [:op_gt_eq, 'uid', 500],
        ]
      ]
    )

    expect(ast).to eql('(|((cn~=Peter Hamilton)(mail=*)(uid>=500)))')
  end

  describe 'single expressions' do
    it 'approximately' do
      ast = decomposer.call([:op_prox, 'cn', 'Peter Hamilton'])
      expect(ast).to eql('(cn~=Peter Hamilton)')
    end

    it 'equals' do
      ast = decomposer.call([:op_equal, 'mail', '*@peterdavidhamilton.com'])
      expect(ast).to eql('(mail=*@peterdavidhamilton.com)')
    end

    it 'greater than' do
      ast = decomposer.call([:op_gt, 'uid', 500])
      expect(ast).to eql('(uid>500)')
    end


    it 'less than or equal' do
      ast = decomposer.call([:op_lt_eq, 'uid', 500])
      expect(ast).to eql('(uid<=500)')
    end
  end

end
