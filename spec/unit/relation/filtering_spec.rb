require 'spec_helper'

describe ROM::LDAP::Relation, 'dataset dsl' do
  include RelationSetup

  describe 'test customers' do

    let(:uids) { %w[barry billy bobby sally] }

    before do
      uids.each { |uid|
        factories[:account,
          uid: uid,
          dn: "uid=#{uid},ou=users,dc=example,dc=com"]
      }
    end

    after do
      uids.each { |uid| accounts.where(uid: uid).delete }
    end

    it '#equals' do
      sandbox.equals(uid: 'billy').count.must_equal(1)
      # sandbox.equals(mail: 'test*.com').count.must_equal(10)
    end

    it '#not' do
      skip 'returns 16' # FIXME: sandbox relation is wrong
      sandbox.not(uid: 'susan').count.must_equal(4)
    end

    it '#present' do
      skip 'returns 14' # FIXME: sandbox relation is wrong
      sandbox.present(:gidnumber).count.must_equal(4)
    end

    it '#begins' do
      sandbox.begins(uid: 'b').count.must_equal(3)
    end

    it '#ends' do
      sandbox.ends(uid: 'by').count.must_equal(1)
    end

    it '#contains' do
      sandbox.contains(uid: 'b').count.must_equal(3)
    end

    it '#within' do
      # sandbox.within(uid: 'es').count.must_equal(10)
    end

    it '#gte' do
      # sandbox.gte(uid: 'es').count.must_equal(10)
    end

    it '#lte' do
      # sandbox.lte(uid: 'es').count.must_equal(10)
    end

    it '#outside' do
      # sandbox.outside(uid: 'es').count.must_equal(10)
    end
  end



  # describe 'test customers' do
  #   it '#equals' do
  #     accounts.equals(uid: 'root').count.must_equal(1)
  #   end

  #   # 10 x test plus ou
  #   it '#not' do
  #     accounts.not(uid: 'root').count.must_equal(11)
  #   end

  #   it '#present' do
  #     customers.present(:gidnumber).count.must_equal(10)
  #   end

  #   it '#begins' do
  #     customers.begins(uid: 'test').count.must_equal(10)
  #   end

  #   it '#ends' do
  #     customers.ends(uid: '9').count.must_equal(1)
  #   end

  #   it '#contains' do
  #     customers.contains(uid: 'es').count.must_equal(10)
  #     customers.contains(objectclass: 'person').count.must_equal(11)
  #   end

  #   it '#within' do
  #   end

  #   it '#gte' do
  #     # customers.gte(gidnumber: 9997).to_a.must_be_empty
  #     # customers.count.must_equal 11
  #   end

  #   it '#lte' do
  #     # customers.gte(gidnumber: 9997).to_a.must_be_empty
  #   end

  #   it '#outside' do
  #   end
  # end

end
