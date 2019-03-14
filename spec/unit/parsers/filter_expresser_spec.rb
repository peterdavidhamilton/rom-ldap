RSpec.describe ROM::LDAP::Parsers::FilterExpresser do

  include_context 'parser attrs'

  let(:parser) { ROM::LDAP::Parsers::FilterExpresser }

  describe 'complex AND join' do

    let(:input) do
      '(&(&(objectClass=person)(uidNumber>=34))(mail~=*@example.com))'
    end

    it 'returns a symbolic operator' do
      expect(output.op).to eql(:con_and)
    end

    it 'returns a nested Expression' do
      expect(output).to be_a(ROM::LDAP::Expression)
      expect(output.left).to be_a(ROM::LDAP::Expression)
      expect(output.right).to be_a(ROM::LDAP::Expression)
    end

    it 'splits each statement' do
      expect(output.right.to_raw_filter).to eql('mail~=*@example.com')
      expect(output.left.to_s).to eql('(&(objectClass=person)(uidNumber>=34))')
      expect(output.left.left.to_raw_filter).to eql('objectClass=person')
      expect(output.left.right.to_s).to eql('(uidNumber>=34)')
    end

    it 'roundtrips' do
      expect(output.to_s).to eql(input)
    end

  end

  describe 'extra whitespace' do

    # FIXME: spaces between |( break this
    let(:input) do
      ' (  |(  |( baz = foo bar )  ( baz >= 100 )  ) ( foo ~= bar )   ) '
    end

    it 'roundtrips' do
      expect(output.to_s).to eql('(|(|(baz=foo bar)(baz>=100))(foo~=bar))')
    end
  end




  describe 'complex OR join' do

    let(:input) do
      '(|(|(foo=bar)(baz>=100))(quux~=*@example.com))'
    end

    it 'returns a symbolic operator' do
      expect(output.op).to eql(:con_or)
    end

    it 'returns a nested Expression' do
      expect(output).to be_a(ROM::LDAP::Expression)
      expect(output.left).to be_a(ROM::LDAP::Expression)
      expect(output.right).to be_a(ROM::LDAP::Expression)
    end

    it 'splits each statement' do
      expect(output.right.to_raw_filter).to eql('quux~=*@example.com')
      expect(output.left.to_s).to eql('(|(foo=bar)(baz>=100))')
      expect(output.left.left.to_raw_filter).to eql('foo=bar')
      expect(output.left.right.to_s).to eql('(baz>=100)')
    end

    it 'roundtrips' do
      expect(output.to_s).to eql(input)
    end

  end
end
