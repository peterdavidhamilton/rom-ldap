require 'spec_helper'

RSpec.describe ROM::LDAP::Functions::ExpressionExporter do

  let(:exporter) { ROM::LDAP::Functions::ExpressionExporter.new }

  describe 'con_and con_and' do
    let(:string) do
      '(&(&(objectclass=person)(uidnumber>=34))(mail~=*@example.com))'
    end

    it 'parse' do
      expression = exporter.call(string)
      expect(expression.to_s).to eql(string)

      # expect(expression.op).to eql(:con_and)
      # expect(expression.left.op).to eql(:con_and)
      # expect(expression.right.op).to eql(:op_prox)
    end
  end

end
