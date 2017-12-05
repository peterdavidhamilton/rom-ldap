RSpec.describe 'Plugin / Pagination' do

  let(:formatter) { nil }
  include_context 'relations'

  describe '#page' do
    it 'allow to call with stringify number' do
      expect(accounts.page('1').to_a.size).to eql(4)
    end

    it 'preserves existing modifiers' do
      expect(accounts.where(uid: 'root').page(1).to_a.size).to eql(1)
    end
  end

  describe '#per_page' do
    it 'allow to call with stringify number' do
      expect {
        container.relations[:accounts].per_page('5')
      }.to_not raise_error
    end

    it 'returns paginated relation with provided limit' do
      accounts = container.relations[:accounts].page(2).per_page(3)

      expect(accounts.dataset.opts[:offset]).to eql(3)
      expect(accounts.dataset.opts[:limit]).to eql(3)

      expect(accounts.pager.current_page).to eql(2)
      expect(accounts.pager.total).to eql(11)
      expect(accounts.pager.total_pages).to eql(4)

      expect(accounts.pager.next_page).to eql(3)
      expect(accounts.pager.prev_page).to eql(1)

      expect(accounts.pager.limit_value).to eql(3)
    end
  end

  describe '#total_pages' do
    it 'returns a single page when elements are a perfect fit' do
      accounts = container.relations[:accounts].page(1).per_page(3)
      expect(accounts.pager.total_pages).to eql(4)
    end

    it 'returns the exact number of pages to accommodate all elements' do
      accounts = container.relations[:accounts].page(1).per_page(20)
      expect(accounts.pager.total_pages).to eql(1)
    end
  end

  describe '#pager' do
    it 'returns a pager with pagination meta-info' do
      accounts = container.relations[:accounts].page(1)

      expect(accounts.dataset.opts[:offset]).to eql(0)
      expect(accounts.dataset.opts[:limit]).to eql(4)

      expect(accounts.pager.total).to eql(11)
      expect(accounts.pager.total_pages).to eql(3)

      expect(accounts.pager.current_page).to eql(1)
      expect(accounts.pager.next_page).to eql(2)
      expect(accounts.pager.prev_page).to be_nil

      accounts = container.relations[:accounts].page(2)

      expect(accounts.pager.current_page).to eql(2)
      expect(accounts.pager.next_page).to eql(3)
      expect(accounts.pager.prev_page).to eql(1)

      accounts = container.relations[:accounts].page(3)

      expect(accounts.pager.next_page).to be_nil
      expect(accounts.pager.prev_page).to eql(2)
    end
  end
end
