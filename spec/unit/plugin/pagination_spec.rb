RSpec.describe ROM::LDAP::Relation do

  include_context 'entries', 'open_ldap'

  before do
    factories[:entry, cn: 'start']
    49.times { factories[:entry] }
  end

  describe 'Pagination plugin' do

    it 'with 50 in the collection' do
      expect(entries.count).to eql(50)
    end


    describe '#page' do
      it 'permits stringified integers' do
        expect(entries.page('1').count).to eql(13)
      end

      it 'preserves existing modifiers' do
        expect(entries.where(cn: 'start').page(1).count).to eql(1)
      end
    end



    describe '#per_page' do
      it 'permits stringified integers' do
        expect { entries.per_page('5') }.to_not raise_error
      end

      it 'limits the collection returned' do
        expect(entries.page(2).per_page(3).dataset.opts[:offset]).to eql(3)
        expect(entries.page(2).per_page(3).dataset.opts[:limit]).to eql(3)

        expect(entries.page(2).per_page(3).pager.limit_value).to eql(3)

        expect(entries.page(2).per_page(3).pager.current_page).to eql(2)
        expect(entries.page(1).per_page(10).pager.total).to eql(50)
        expect(entries.page(1).per_page(5).pager.total_pages).to eql(10)

        expect(entries.page(5).per_page(7).pager.next_page).to eql(6)
        expect(entries.page(5).per_page(7).pager.prev_page).to eql(4)
      end
    end



    describe '#total_pages' do
      it 'calculates pages required' do
        # 50/3 = 16.6667
        expect(entries.page(1).per_page(3).pager.total_pages).to eql(17)
        # 50/20 = 2.5
        expect(entries.page(2).per_page(20).pager.total_pages).to eql(3)
      end
    end



    describe '#pager' do
      it 'contains pagination meta-info' do
        expect(entries.page(1).dataset.opts[:offset]).to eql(0)
        expect(entries.page(1).dataset.opts[:limit]).to eql(13)

        expect(entries.page(1).pager.total).to eql(50)
        expect(entries.page(1).pager.total_pages).to eql(4)

        expect(entries.page(1).pager.current_page).to eql(1)
        expect(entries.page(1).pager.next_page).to eql(2)
        expect(entries.page(1).pager.prev_page).to be_nil

        expect(entries.page(2).pager.current_page).to eql(2)
        expect(entries.page(2).pager.next_page).to eql(3)
        expect(entries.page(2).pager.prev_page).to eql(1)

        expect(entries.page(4).pager.next_page).to be_nil
        expect(entries.page(4).pager.prev_page).to eql(3)
      end
    end
  end
end
