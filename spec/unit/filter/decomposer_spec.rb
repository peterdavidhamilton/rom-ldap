require 'spec_helper'

require 'rom/ldap/filter/decomposer'

RSpec.describe ROM::LDAP::Filter::Decomposer do

  let(:decomposer) { ROM::LDAP::Filter::Decomposer.new }

  # like john or is smith, and missing uid
  it '#ast to filter' do

    ast = decomposer.call(
      [
        :con_and,
        [
          [:con_or,  [[:op_prox, 'cn', 'John'], [:op_equal, 'sn', 'Smith']]],
          [:con_not, [:op_equal, 'uid', :wildcard]]
        ]
      ]
    )

    expect(ast).to eql('(&(|(cn~=John)(sn=Smith))(!(uid=*)))')
  end


  # like john or is smith, and missing uid
  # it '#ast to filter' do

  #   ast = recompiler.new.call(
  #     [
  #       :con_and,
  #       [
  #         [:con_or,  [[:op_prox, 'cn', 'John'], [:op_equal, 'sn', 'Smith']]],
  #         [:con_not, [:op_equal, 'uid', :val_wild]]
  #       ]
  #     ]
  #   )

  #   expect(ast).to eql('(&(|(cn~=John)(sn=Smith))(!(uid=*)))')
  # end

  describe 'single expressions' do
    it 'approximately' do
      ast = decomposer.call([:op_prox, 'cn', 'John'])
      expect(ast).to eql('(cn~=John)')
    end

    it 'equals' do
      ast = decomposer.call([:op_equal, 'mail', '*@example.com'])
      expect(ast).to eql('(mail=*@example.com)')
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
