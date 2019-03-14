RSpec.describe ROM::LDAP::Parsers::ASTRecompiler do

  include_context 'parser attrs'

  let(:parser) { ROM::LDAP::Parsers::ASTRecompiler }

  describe 'AST to Filter' do

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


    it 'outputs valid ldap filter' do
      expect(output).to eql(
        '(
          &
          (
            |
            (originalOne~=val_1)
            (originalThree>=val_3)
            (originalFour<=val_4)
            (originalFive=*val_5*)
          )
          (
            !(originalTwo=*)
          )
        )'.delete(" \n"))
    end
  end



  # unknown operators are flagged in filter
  describe '[:foo, "gn", "bar"]' do
    let(:input) { [:foo, 'gn', 'bar'] }

    it { expect(output).to eql('(gn???bar)') }
  end
end
