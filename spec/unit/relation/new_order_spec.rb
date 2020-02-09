RSpec.describe ROM::LDAP::Relation, '#order' do

  include_context 'people'

  let(:forward)  do
    people.order(attribute).project(attribute).to_a
  end

  let(:backward) do
    people.order(attribute).reverse.project(attribute).to_a
  end

  with_vendors 'apache_ds', 'open_dj', '389_ds' do

    describe 'integers' do
      before do
        (0..9).sort_by { rand }.each { |i|
          factories[:person, uid_number: i]
        }
      end

      let(:attribute) { :uid_number }

      it 'in numerical order' do
        expect(forward).to eql([
          { uid_number: 0 },
          { uid_number: 1 },
          { uid_number: 2 },
          { uid_number: 3 },
          { uid_number: 4 },
          { uid_number: 5 },
          { uid_number: 6 },
          { uid_number: 7 },
          { uid_number: 8 },
          { uid_number: 9 }
        ])
      end

      it 'in reverse numerical order' do
        expect(backward).to eql([
            { uid_number: 9 },
            { uid_number: 8 },
            { uid_number: 7 },
            { uid_number: 6 },
            { uid_number: 5 },
            { uid_number: 4 },
            { uid_number: 3 },
            { uid_number: 2 },
            { uid_number: 1 },
            { uid_number: 0 }
        ])
      end
    end


    describe 'strings' do
      before do
        %w[
          Bohr
          Curie
          Einstein
          Franklin
          Hawking
          Hopper
          Lavoisier
          Sagan
          Tesla
          Turing
        ].sort_by { rand }.each { |w| factories[:person, sn: w] }
      end

      let(:attribute) { :sn }

      it 'in alphabetical order' do
        expect(forward).to eql([
          { sn: ['Bohr']      },
          { sn: ['Curie']     },
          { sn: ['Einstein']  },
          { sn: ['Franklin']  },
          { sn: ['Hawking']   },
          { sn: ['Hopper']    },
          { sn: ['Lavoisier'] },
          { sn: ['Sagan']     },
          { sn: ['Tesla']     },
          { sn: ['Turing']    }
        ])
      end

      it 'in reverse alphabetical order' do
        expect(backward).to eql([
          { sn: ['Turing']    },
          { sn: ['Tesla']     },
          { sn: ['Sagan']     },
          { sn: ['Lavoisier'] },
          { sn: ['Hopper']    },
          { sn: ['Hawking']   },
          { sn: ['Franklin']  },
          { sn: ['Einstein']  },
          { sn: ['Curie']     },
          { sn: ['Bohr']      }
        ])
      end

    end
  end

end
