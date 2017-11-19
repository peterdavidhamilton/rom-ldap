require 'spec_helper'

RSpec.describe ROM::LDAP::Functions::QueryExporter do
  let(:exporter) { ROM::LDAP::Functions::QueryExporter.new }

  describe 'con_and' do
    let(:string) { '(&(objectclass=person)(uidnumber>=34)(mail~=*@example.com))' }

    it 'con_and' do
      ast = exporter.call(string)

      expect(ast).to eql(
        [
          :con_and,
          [
            [:op_eql, 'objectclass', 'person'],
            [:op_gte, 'uidnumber', '34'],
            [:op_prx,  'mail', '*@example.com']
          ]
        ]
      )
    end
  end

  describe 'con_not con_and' do
    let(:string) { '(!(&(objectclass=person)(uidnumber<=2)(sn=hamilton)(givenname=peter)))' }

    it 'con_not con_and' do
      ast = exporter.call(string)

      expect(ast).to eql(
        [
          :con_not,
          [
            :con_and,
            [
              [:op_eql, 'objectclass', 'person'],
              [:op_lte, 'uidnumber', '2'],
              [:op_eql, 'sn', 'hamilton'],
              [:op_eql, 'givenname', 'peter']
            ]
          ]
        ]
      )
    end
  end

  describe 'con_not con_or' do
    let(:string) { '(!(|(uidnumber>=10)(gidnumber<=34)))' }

    it 'con_not con_or' do
      ast = exporter.call(string)

      expect(ast).to eql(
        [
          :con_not,
          [
            :con_or,
            [
              [:op_gte, 'uidnumber', '10'],
              [:op_lte, 'gidnumber', '34']
            ]
          ]
        ]
      )
    end
  end


 describe 'and (eq pres pres)' do
    let(:string) { '(|(uidnumber=*)(mail=*))' }

    it '#parse' do
      ast = exporter[string]

      expect(ast).to eql(
        [
          :con_or,
          [
            [:op_eql, 'uidnumber', :wildcard],
            [:op_eql, 'mail',      :wildcard]
          ]
        ]
      )
    end
  end

  describe 'and (eq pres pres)' do
    let(:string) { '(&(objectclass=person)(uidnumber=*)(blocked=TRUE))' }

    it '#parse' do
      ast = exporter.(string)

      expect(ast).to eql(
        [
          :con_and,
          [
            [:op_eql, 'objectclass', 'person'],
            [:op_eql, 'uidnumber',   :wildcard],
            [:op_eql, 'blocked',     true]
          ]
        ]
      )
    end
  end

  describe 'and (eq pres pres)' do
    let(:string) { '(&(|(cn~=John)(sn=Smith))(!(uid=*)))' }

    it '#parse' do
      ast = exporter.call(string).to_s

      expect(ast).to eql(
        "[:con_and, [[:con_or, [[:op_prx, \"cn\", \"John\"], [:op_eql, \"sn\", \"Smith\"]]], [:con_not, [:op_eql, \"uid\", :wildcard]]]]"

        # [
        #   :con_and,
        #   [
        #     [:con_or,  [[:op_prx, 'cn', 'John'], [:op_eql, 'sn', 'Smith']]],
        #     [:con_not, [:op_eql, 'uid', :wildcard]]
        #   ]
        # ]
      )
    end
  end
end
