RSpec.describe ROM::LDAP::Relation, 'encoding' do

  include_context 'people'

  let(:entry) { people.where(cn: encoded).one }

  with_vendors do

    describe 'using eucCN' do

      let(:encoded) { '李振藩'.encode!('eucCN') }

      before do
        directory.add(
          dn: "cn=Lee Jun-fan,#{base}",
          cn: ['Lee Jun-fan', encoded],
          sn: 'Lee',
          object_class: %w[person]
        )
      end

      it 'returns UTF-8 values' do
        expect(entry[:cn]).to eq(['Lee Jun-fan', '李振藩'])
        expect(entry[:cn][1].encoding.name).to eql('UTF-8')
      end

    end

    describe 'using eucKR' do

      let(:encoded) { '최홍희'.encode!('eucKR') }

      before do
        directory.add(
          dn: "cn=Choi Hong Hi,#{base}",
          cn: ['Choi Hong Hi', encoded],
          sn: 'Choi',
          object_class: %w[person]
        )
      end

      it 'returns UTF-8 values' do
        expect(entry[:cn]).to eq(['Choi Hong Hi', '최홍희'])
        expect(entry[:cn][1].encoding.name).to eql('UTF-8')
      end

    end

    describe 'using eucJP' do

      let(:encoded) { '嘉納 治五郎'.encode!('eucJP') }

      before do
        directory.add(
          dn: "cn=Kanō Jigorō,#{base}",
          cn: ['Kanō Jigorō', encoded],
          sn: 'Kanō',
          object_class: %w[person]
        )
      end

      it 'returns UTF-8 values' do
        expect(entry[:cn]).to eq(['Kanō Jigorō', '嘉納 治五郎'])
        expect(entry[:cn][1].encoding.name).to eql('UTF-8')
      end

    end






  end
end
