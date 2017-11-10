require 'spec_helper'

require 'rom/ldap/filter/compiler'

RSpec.describe ROM::LDAP::Filter::Compiler do

  let(:ldap_string) do
    '(&(objectclass=person)(uidnumber=*)(mail=*))'
  end

  let(:compiler) do
    ROM::LDAP::Filter::Compiler
  end

  describe 'scanner logic' do
    it 'receives string' do
      expect(compiler.new(string: ldap_string).parse).to eql [:and]
    end
  end

end
