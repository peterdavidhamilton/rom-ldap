require 'spec_helper'

RSpec.describe ROM::LDAP::Functions::ExpressionExporter do

  let(:exporter) { ROM::LDAP::Functions::ExpressionExporter.new }

  describe 'roundtrip' do

    it 'parse' do
      string = '(&(&(objectclass=person)(uidnumber>=34))(mail~=*@example.com))'
      expression = exporter.call(string)

      expect(expression.to_s).to eql(string)
    end
  end

end
