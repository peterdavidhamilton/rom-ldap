require 'spec_helper'

describe ROM::LDAP::Relation, 'command interface' do
  include RelationSetup

  it '#update and #delete return an empty array for an empty dataset' do
    accounts.where(uid: 'foo').update(mail: 'foo@bar').must_equal []
    accounts.where(uid: 'bar').delete.must_equal []
  end

  it '#insert -> #update -> #delete' do
    proc { accounts.insert(cn: 'The Dark Knight') }.must_raise ROM::LDAP::OperationError

    accounts.insert(
      dn: 'uid=batman,ou=users,dc=example,dc=com',
      cn: 'The Dark Knight',
      uid: 'batman',
      sn: 'Wayne',
      uidnumber: 1003,
      gidnumber: 1050,
      'apple-imhandle': 'bruce-wayne',
      objectclass: %w[extensibleobject inetorgperson apple-user]
    ).must_equal true

    accounts.where(uid: 'batman').one[:cn].must_equal ['The Dark Knight']
    accounts.where(uid: 'batman').one[:appleimhandle].must_equal ['bruce-wayne']
    accounts.where(uid: 'batman').update(missing: 'Hulk').must_equal [false]
    accounts.where(uid: 'batman').update(sn: 'Stark').must_equal [true]
    accounts.where(uid: 'batman').one[:sn].must_equal ['Stark']
    accounts.where(uid: 'batman').delete.must_equal [true]
    accounts.where(uid: 'batman').one.must_be_nil
  end

end
