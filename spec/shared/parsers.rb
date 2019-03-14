RSpec.shared_context 'parser attrs' do

  let(:attributes) {
    [
      { name: :_Formatted_1, canonical: 'originalOne'   },
      { name: :_Formatted_2, canonical: 'originalTwo'   },
      { name: :_Formatted_3, canonical: 'originalThree' },
      { name: :_Formatted_4, canonical: 'originalFour'  },
      { name: :_Formatted_5, canonical: 'originalFive'  }
    ]
  }

  let(:output) { parser.new(input, schemas: attributes).call }

end
