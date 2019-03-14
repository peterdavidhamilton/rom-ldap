RSpec.describe ROM::LDAP::Parsers::FilterAbstracter do

  include_context 'parser attrs'

  let(:parser) { ROM::LDAP::Parsers::FilterAbstracter }

  describe '(&(originalOne=foo)(originalTwo>=34)(originalThree~=*@example.com))' do
    let(:input) { '(&(originalOne=foo)(originalTwo>=34)(originalThree~=*@example.com))' }

    it {
      expect(output).to eql(
        [
          :con_and,
          [
            [:op_eql, :_Formatted_1, 'foo'],
            [:op_gte, :_Formatted_2, '34'],
            [:op_prx, :_Formatted_3, '*@example.com']
          ]
        ]
      )
    }
  end

  describe '(!(&(originalThree=bar)(originalFive<=2)(originalOne=baz)(originalFour=*peter*)))' do
    let(:input) { '(!(&(originalThree=bar)(originalFive<=2)(originalOne=baz)(originalFour=*peter*)))' }

    it {
      expect(output).to eql(
        [
          :con_not,
          [
            :con_and,
            [
              [:op_eql, :_Formatted_3, 'bar'],
              [:op_lte, :_Formatted_5, '2'],
              [:op_eql, :_Formatted_1, 'baz'],
              [:op_eql, :_Formatted_4, '*peter*']
            ]
          ]
        ]
      )
    }
  end

  describe '(!(|(originalFive>=10)(originalOne<=34)))' do
    let(:input) { '(!(|(originalFive>=10)(originalOne<=34)))' }

    it {
      expect(output).to eql(
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
    }
  end


 describe '(|(originalOne=*)(originalTwo=*))' do
    let(:input) { '(|(originalOne=*)(originalTwo=*))' }

    it {
      expect(output).to eql(
        [
          :con_or,
          [
            [:op_eql, :_Formatted_1, :wildcard],
            [:op_eql, :_Formatted_2, :wildcard]
          ]
        ]
      )
    }
  end

  describe '(&(objectClass=person)(uidNumber=*)(blocked=TRUE))' do
    let(:input) { '(&(objectClass=person)(uidNumber=*)(blocked=TRUE))' }

    it {
      expect(output).to eql(
        [
          :con_and,
          [
            [:op_eql, 'objectClass', 'person'],
            [:op_eql, 'uidNumber',   :wildcard],
            [:op_eql, 'blocked',     true]
          ]
        ]
      )
    }
  end

  describe '(&(|(cn~=John)(sn=Smith))(!(uid=*)))' do
    let(:input) { '(&(|(cn~=John)(sn=Smith))(!(uid=*)))' }

    it {
      expect(output).to eql(
        [
          :con_and,
          [
            [:con_or,  [[:op_prx, 'cn', 'John'], [:op_eql, 'sn', 'Smith']]],
            [:con_not, [:op_eql, 'uid', :wildcard]]
          ]
        ]
      )
    }

  end

  # unknown attributes pass through unformatted
  describe '(&(unknownAttr<=foo)(sn:1.2.3.4.5.6.7.8.9:=Smith))' do
    let(:input) { '(&(unknownAttr<=foo)(sn:1.2.3.4.5.6.7.8.9:=Smith))' }

    it {
      expect(output).to eql(
        [
          :con_and,
          [
            [:op_lte, 'unknownAttr', 'foo'],
            [:op_ext, 'sn:1.2.3.4.5.6.7.8.9', 'Smith']
          ]
        ]
      )
    }

  end

end
