require 'spec_helper'

RSpec.describe ROM::LDAP::Filter::Transformer::Parser do

  let(:parser) { ROM::LDAP::Filter::Transformer::Parser.new }

  describe 'con_and con_and' do
    let(:string) do
      '(&(&(objectclass=person)(uidnumber>=34))(mail~=*@example.com))'
    end

    it 'parse' do
      expression = parser.call(string)
      expect(expression.to_s).to eql(string)

      # expect(expression.op).to eql(:con_and)
      # expect(expression.left.op).to eql(:con_and)
      # expect(expression.right.op).to eql(:op_prox)
    end
  end

end
