require 'spec_helper'

RSpec.describe ROM::LDAP::Filter::Parser do

  let(:parser) { ROM::LDAP::Filter::Parser.new(ROM::LDAP::Filter::Builder) }

  it 'ascii' do
    expect(parser.call("(cn=name)")).to be_instance_of(ROM::LDAP::Filter::Builder)
    expect(parser.call("(cn=name)")).to be_instance_of(ROM::LDAP::Filter::Builder)
  end

  it 'multibyte characters' do
    expect(parser.call("(cn=名前)")).to be_kind_of(ROM::LDAP::Filter::Builder)
  end

  it 'brackets' do
    expect(parser.call("(cn=[{something}])")).to be_kind_of(ROM::LDAP::Filter::Builder)
  end

  it 'slash' do
    expect(parser.call("(departmentNumber=FOO//BAR/FOO)")).to be_kind_of(ROM::LDAP::Filter::Builder)
  end

  it 'colons' do
    expect(parser.call("(ismemberof=cn=edu:berkeley:app:calmessages:deans,ou=campus groups,dc=berkeley,dc=edu)")).to be_kind_of(ROM::LDAP::Filter::Builder)
  end


end
