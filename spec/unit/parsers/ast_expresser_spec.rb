RSpec.describe ROM::LDAP::Parsers::ASTExpresser do

  include_context 'parser attrs'

  let(:parser) { ROM::LDAP::Parsers::ASTExpresser }

  describe 'AST to Expression' do

    let(:input) do
      [
        :con_and,
        [
          [
            :con_or,
            [
              [:op_prx, :_Formatted_1, 'val_1'],
              [:op_gte, :_Formatted_3, 'val_3'],
              [:op_lte, :_Formatted_4, 'val_4'],
              [:op_eql, :_Formatted_5, '*val_5*']
            ]
          ],
          [
            :con_not,
            [:op_eql, :_Formatted_2, :wildcard]
          ]
        ]
      ]
    end

    # it 'roundtrips' do
    #   expect(output.to_s).to eql(
    #     "(&(|(originalOne~=val_1)(originalThree>=val_3))(!((originalTwo=*)=)))")
    # end

    it 'returns a symbolic operator' do
      expect(output.op).to eql(:con_and)
    end

    it 'returns nested Expressions' do
      expect(output).to be_a(ROM::LDAP::Expression)
      expect(output.left).to be_a(ROM::LDAP::Expression)
      expect(output.right).to be_a(ROM::LDAP::Expression)
      expect(output.right.left).to be_a(ROM::LDAP::Expression)
    end

    it 'splits each statement' do
      # expect(output.right.to_s).to eql('(!(originalTwo=*))')
      # expect(output.left.to_s).to eql('(|(originalOne~=val_1)(originalThree>=val_3)(originalFour<=val_4)(originalFive=*val_5*))')
      # expect(output.left.left.to_s).to eql('(originalOne~=val_1)')
      # expect(output.left.right.to_s).to eql('(originalThree>=val_3)')
    end


  end
end
