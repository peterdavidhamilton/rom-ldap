require 'spec_helper'

require 'rom/ldap/plugin/pagination'

describe 'Plugin / Pagination' do
  include RelationSetup

  describe '#page' do
    it 'allow to call with stringify number' do
      accounts.page('1').to_a.size.must_equal 4
    end

    it 'preserves existing modifiers' do
      accounts.where(uid: 'root').page(1).to_a.size.must_equal 1
    end
  end

  describe '#per_page' do
    it 'allow to call with stringify number' do
      # accounts.per_page('5').must_be_a Relation
    end

    it 'returns paginated relation with provided limit' do
      accounts = container.relations[:accounts].page(2).per_page(3)

      accounts.dataset.opts[:offset].must_equal 3
      accounts.dataset.opts[:limit].must_equal 3

      accounts.pager.current_page.must_equal 2
      accounts.pager.total.must_equal 11
      accounts.pager.total_pages.must_equal 4

      accounts.pager.next_page.must_equal 3
      accounts.pager.prev_page.must_equal 1

      accounts.pager.limit_value.must_equal 3
    end
  end

  describe '#total_pages' do
    it 'returns a single page when elements are a perfect fit' do
      accounts = container.relations[:accounts].page(1).per_page(3)
      accounts.pager.total_pages.must_equal 4
    end

    it 'returns the exact number of pages to accommodate all elements' do
      accounts = container.relations[:accounts].page(1).per_page(20)
      accounts.pager.total_pages.must_equal 1
    end
  end

  describe '#pager' do
    it 'returns a pager with pagination meta-info' do
      accounts = container.relations[:accounts].page(1)

      accounts.pager.total.must_equal(11)
      accounts.pager.total_pages.must_equal(3)

      accounts.pager.current_page.must_equal(1)
      accounts.pager.next_page.must_equal(2)
      accounts.pager.prev_page.must_equal(nil)

      accounts = container.relations[:accounts].page(2)

      accounts.pager.current_page.must_equal(2)
      accounts.pager.next_page.must_equal(3)
      accounts.pager.prev_page.must_equal(1)

      accounts = container.relations[:accounts].page(3)

      accounts.pager.next_page.must_equal(nil)
      accounts.pager.prev_page.must_equal(2)
    end
  end
end
