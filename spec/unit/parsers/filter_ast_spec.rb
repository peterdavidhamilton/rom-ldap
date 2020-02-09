RSpec.describe 'filter string lexer/parser' do

  let(:attributes) {
    [
      { name: :_Formatted_1, canonical: 'originalOne'   },
      { name: :_Formatted_2, canonical: 'originalTwo'   },
      { name: :_Formatted_3, canonical: 'originalThree' },
      { name: :_Formatted_4, canonical: 'originalFour'  },
      { name: :_Formatted_5, canonical: 'originalFive'  }
    ]
  }

  # Filter > AST
  let(:filter_syntax) { ROM::LDAP::Parsers::FilterSyntax }
  let(:abstract) { filter_syntax.new(filter, attributes).call }

  # AST > Expression
  let(:abstract_syntax) { ROM::LDAP::Parsers::AbstractSyntax }
  let(:expression) { abstract_syntax.new(ast, attributes).call }

  describe ROM::LDAP::Parsers::AbstractSyntax, '#call' do

    context 'when using complex combinations of queries' do

      let(:ast) do
        [
          :con_and,
          [
            [
              :con_or,
              [
                [:op_prx, :_Formatted_1, 'val_1'  ],
                [:op_gte, :_Formatted_3, 'val_3'  ],
                [:op_lte, :_Formatted_4, 'val_4'  ],
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

      it 'builds nested Expression for each query' do
        expect(expression.to_filter).to eql(
          "(&(|(originalOne~=val_1)(originalThree>=val_3)(originalFour<=val_4)(originalFive=*val_5*))(!(originalTwo=*)))"
        )
        expect(expression.to_ast).to eql(
        [
          :con_and,
          [
            [
              :con_or,
              [
                [:op_prx, 'originalOne',    'val_1'   ],
                [:op_gte, 'originalThree',  'val_3'   ],
                [:op_lte, 'originalFour',   'val_4'   ],
                [:op_eql, 'originalFive',   '*val_5*' ]
              ]
            ],
            [
              :con_not,
              [:op_eql, 'originalTwo', '*']
            ]
          ]
        ])
      end
    end


    context 'when value is integer' do

      let(:ast) { [ :con_not, [:op_eql, :_Formatted_1, 10]] }

      it 'value is unchanged' do
        expect(expression.to_filter).to eql('(!(originalOne=10))')
        expect(expression.to_ast).to eql([:con_not, [:op_eql, "originalOne", 10]])
      end
    end

    context 'when value is float' do

      let(:ast) { [ :con_not, [:op_eql, :_Formatted_1, 5.25]] }

      it 'value is unchanged' do
        expect(expression.to_filter).to eql('(!(originalOne=5.25))')
        expect(expression.to_ast).to eql([:con_not, [:op_eql, "originalOne", 5.25]])
      end
    end


    context 'when attribute name is unknown' do

      let(:ast) { [:con_not, [:op_eql, :_Uknown_Attr, 'foo']] }

      it 'attribute is not formatted' do
        expect(expression.to_filter).to eql('(!(_Uknown_Attr=foo))')
        expect(expression.to_ast).to eql(ast)
      end

    end
  end


  describe ROM::LDAP::Parsers::FilterSyntax, '#call' do

    context 'when using different operators' do

      let(:filter) { '(&(originalOne=foo)(originalTwo>=34)(originalThree~=*@example.com))' }

      it 'converts to symbol form' do
        expect(abstract).to eql(
          [
            :con_and,
            [
              [:op_eql, :_Formatted_1, 'foo'          ],
              [:op_gte, :_Formatted_2, '34'           ],
              [:op_prx, :_Formatted_3, '*@example.com']
            ]
          ]
        )
      end
    end

    context 'when the filter uses joins or negation' do

      let(:filter) { '(!(&(originalThree=bar)(originalFive<=2)(originalOne=baz)(originalFour=*peter*)))' }

      it 'constructors are converted to symbols' do
        expect(abstract).to eql(
          [
            :con_not,
            [
              :con_and,
              [
                [:op_eql, :_Formatted_3, 'bar'    ],
                [:op_lte, :_Formatted_5, '2'      ],
                [:op_eql, :_Formatted_1, 'baz'    ],
                [:op_eql, :_Formatted_4, '*peter*']
              ]
            ]
          ]
        )
      end
    end

    context 'when query has numerical values' do
      let(:filter) { '(!(|(originalFive>=10)(originalOne<=34)))' }

      it 'they are returned as strings' do
        expect(abstract).to eql(
          [
            :con_not,
            [
              :con_or,
              [
                [:op_gte, :_Formatted_5, '10'],
                [:op_lte, :_Formatted_1, '34']
              ]
            ]
          ]
        )
      end
    end


    context 'when using asterisks' do
      let(:filter) { '(|(originalOne=*)(originalTwo=*))' }

      it 'wilcards are converted to symbols' do
        expect(abstract).to eql(
          [
            :con_or,
            [
              [:op_eql, :_Formatted_1, :wildcard],
              [:op_eql, :_Formatted_2, :wildcard]
            ]
          ]
        )
      end
    end

    context 'when using boolean values' do
      let(:filter) { '(&(objectClass=person)(uidNumber=*)(blocked=TRUE))' }

      it 'TrueClass/FalseClass are returned' do
        expect(abstract).to eql(
          [
            :con_and,
            [
              [:op_eql, 'objectClass', 'person'],
              [:op_eql, 'uidNumber',   :wildcard],
              [:op_eql, 'blocked',     true]
            ]
          ]
        )
      end
    end

    context 'when combining nested expressions' do
      let(:filter) { '(&(|(cn~=John)(sn=Smith))(!(uid=*)))' }

      it 'it returns each in an abstract syntax branch' do
        expect(abstract).to eql(
          [
            :con_and,
            [
              [:con_or,  [[:op_prx, 'cn', 'John'], [:op_eql, 'sn', 'Smith']]],
              [:con_not, [:op_eql, 'uid', :wildcard]]
            ]
          ]
        )
      end

    end

    context 'when attribute is not known' do
      let(:filter) { '(&(unknownAttr<=foo)(sn:1.2.3.4.5.6.7.8.9:=Smith))' }

      it 'is not formatted' do
        expect(abstract).to eql(
          [
            :con_and,
            [
              [:op_lte, 'unknownAttr', 'foo'],
              [:op_ext, 'sn:1.2.3.4.5.6.7.8.9', 'Smith']
            ]
          ]
        )
      end

    end

  end


end
