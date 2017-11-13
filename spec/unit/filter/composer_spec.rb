require 'spec_helper'

require 'rom/ldap/filter/composer'

RSpec.describe ROM::LDAP::Filter::Composer do
  let(:composer) { ROM::LDAP::Filter::Composer.new }

  describe 'and x3 (eq gt prox)' do
    let(:string) { '(&(objectclass=person)(uidnumber>=34)(mail~=*@example.com))' }

    it 'parse' do
      ast = composer.call(string)

      expect(ast).to eql(
        [
          :con_and,
          [
            [:op_equal, 'objectclass', 'person'],
            [:op_gt_eq, 'uidnumber', '34'],
            [:op_prox,  'mail', '*@example.com']
          ]
        ]
      )
    end
  end

  describe 'not and x4 (eq lt sn)' do
    let(:string) { '(!(&(objectclass=person)(uidnumber<2)(sn=hamilton)(givenname=peter)))' }

    it 'parse' do
      ast = composer.call(string)

      expect(ast).to eql(
        [
          :con_not,
          [
            :con_and,
            [
              [:op_equal, 'objectclass', 'person'],
              [:op_lt, 'uidnumber', '2'],
              [:op_equal, 'sn', 'hamilton'],
              [:op_equal, 'givenname', 'peter']
            ]
          ]
        ]
      )
    end
  end

  describe 'not then or (gt lt)' do
    let(:string) { '(!(|(uidnumber>=10)(gidnumber<=34)))' }

    it '#parse' do
      ast = composer.call(string)

      expect(ast).to eql(
        [
          :con_not,
          [
            :con_or,
            [
              [:op_gt_eq, 'uidnumber', '10'],
              [:op_lt_eq, 'gidnumber', '34']
            ]
          ]
        ]
      )
    end
  end


 describe 'and (eq pres pres)' do
    let(:string) { '(|(uidnumber=*)(mail=*))' }

    it '#parse' do
      ast = compiler[string]

      expect(ast).to eql(
        [
          :con_or,
          [
            [:op_equal, 'uidnumber', :wildcard],
            [:op_equal, 'mail',      :wildcard]
          ]
        ]
      )
    end
  end

  describe 'and (eq pres pres)' do
    let(:string) { '(&(objectclass=person)(uidnumber=*)(blocked=TRUE))' }

    it '#parse' do
      ast = compiler.(string)

      expect(ast).to eql(
        [
          :con_and,
          [
            [:op_equal, 'objectclass', 'person'],
            [:op_equal, 'uidnumber',   :wildcard],
            [:op_equal, 'blocked',     true]
          ]
        ]
      )
    end
  end

  describe 'and (eq pres pres)' do
    let(:string) { '(&(|(cn~=John)(sn=Smith))(!(uid=*)))' }

    it '#parse' do
      ast = composer.call(string).to_s

      expect(ast).to eql(
        "[:con_and, [[:con_or, [[:op_prox, \"cn\", \"John\"], [:op_equal, \"sn\", \"Smith\"]]], [:con_not, [:op_equal, \"uid\", :wildcard]]]]"

        # [
        #   :con_and,
        #   [
        #     [:con_or,  [[:op_prox, 'cn', 'John'], [:op_equal, 'sn', 'Smith']]],
        #     [:con_not, [:op_equal, 'uid', :wildcard]]
        #   ]
        # ]
      )
    end
  end
end
