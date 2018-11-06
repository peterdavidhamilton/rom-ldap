RSpec.describe ROM::LDAP::Relation do

  before do
    conf.relation(:birds) do
      schema('(species=*)', infer: true)
      use :pagination
      per_page 13
    end
  end

  include_context 'animals'

  describe 'Pagination plugin' do

    subject(:birds) { relations.birds }

    before do
      factories[:animal, :bird, cn: 'Robin']

      49.times { factories[:animal, :bird] }
    end

    after do
      birds.delete
    end

    it 'with 50 in the collection' do
      expect(birds.count).to eql(50)
    end



    describe '#page' do
      it 'permits stringified integers' do
        expect(birds.page('1').count).to eql(13)
      end

      it 'preserves existing modifiers' do
        expect(birds.where(cn: 'Robin').page(1).count).to eql(1)
      end
    end



    describe '#per_page' do
      it 'permits stringified integers' do
        expect { birds.per_page('5') }.to_not raise_error
      end

      it 'limits the collection returned' do
        expect(birds.page(2).per_page(3).dataset.opts[:offset]).to eql(3)
        expect(birds.page(2).per_page(3).dataset.opts[:limit]).to eql(3)

        expect(birds.page(2).per_page(3).pager.limit_value).to eql(3)

        expect(birds.page(2).per_page(3).pager.current_page).to eql(2)
        expect(birds.page(1).per_page(10).pager.total).to eql(50)
        expect(birds.page(1).per_page(5).pager.total_pages).to eql(10)

        expect(birds.page(5).per_page(7).pager.next_page).to eql(6)
        expect(birds.page(5).per_page(7).pager.prev_page).to eql(4)
      end
    end



    describe '#total_pages' do
      it 'returns a single page when elements are a perfect fit' do
        expect(birds.page(1).per_page(3).pager.total_pages).to eql(17)
      end

      it 'returns the exact number of pages to accommodate all elements' do
        expect(birds.page(1).per_page(20).pager.total_pages).to eql(3)
      end
    end



    describe '#pager' do
      it 'contains pagination meta-info' do
        expect(birds.page(1).dataset.opts[:offset]).to eql(0)
        expect(birds.page(1).dataset.opts[:limit]).to eql(13)

        expect(birds.page(1).pager.total).to eql(50)
        expect(birds.page(1).pager.total_pages).to eql(4)

        expect(birds.page(1).pager.current_page).to eql(1)
        expect(birds.page(1).pager.next_page).to eql(2)
        expect(birds.page(1).pager.prev_page).to be_nil

        expect(birds.page(2).pager.current_page).to eql(2)
        expect(birds.page(2).pager.next_page).to eql(3)
        expect(birds.page(2).pager.prev_page).to eql(1)

        expect(birds.page(4).pager.next_page).to be_nil
        expect(birds.page(4).pager.prev_page).to eql(3)
      end
    end
  end
end
