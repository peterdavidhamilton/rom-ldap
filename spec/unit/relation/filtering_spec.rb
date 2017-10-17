require 'spec_helper'

describe ROM::LDAP::Relation, 'dataset dsl' do
  include RelationSetup

  let(:user_name) { Faker::Internet.unique.user_name }

  before do
    factories[:account,
      uid: user_name,
      dn: "uid=#{user_name},ou=users,dc=example,dc=com"]
  end

  after do
    accounts.where(uid: user_name).delete
  end

  it '#equals' do
  end

  it '#not' do
  end

  it '#present' do
  end

  it '#begins' do
    accounts.begins(uid: 'test').count.must_equal(10)
  end

  it '#ends' do
  end

  it '#contains' do
  end

  it '#within' do
  end

  it '#gte' do
    # customers.gte(gidnumber: 9997).to_a.must_be_empty
    # customers.count.must_equal 11
  end

  it '#lte' do
  end

  it '#outside' do
  end

end
