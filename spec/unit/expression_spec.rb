RSpec.describe ROM::LDAP::Expression do

  let(:exp) do
    described_class.new(op: :op_eql, field: 'objectClass', value: 'person')
  end

  context 'of attribute and value' do
    it '#inspect reveals raw filter' do
      expect(exp.inspect).to eql("#<ROM::LDAP::Expression objectClass=person />")
    end

    it '#to_filter (to_s)' do
      expect(exp.to_filter).to eql("(objectClass=person)")
    end

    it '#to_ast (to_a)' do
      expect(exp.to_ast).to eql([:op_eql, 'objectClass', 'person'])
    end

    it '#to_ber' do
      expect(exp.to_ber).to eql("\xA3\x15\x04\vobjectClass\x04\x06person".b)
    end
  end


  describe 'join or negation' do
    let(:negation) do
      described_class.new(op: :con_not, exps: [exp])
    end

    it '#to_ast' do
      expect(negation.to_ast).to eql([
        :con_not,
        [:op_eql, 'objectClass', 'person']
      ])
    end

  end
end
