require 'spec_helper'

describe ROM::LDAP::Relation, 'command interface' do
  include RelationSetup

  it '#update and #delete return an empty array for an empty dataset' do
    accounts.where(uid: 'missing').update(mail: '').must_equal []
    accounts.where(uid: 'missing').delete.must_equal []
  end

  it '#insert -> #update -> #delete' do
    # #insert raises error when tuple is incomplete
    proc { accounts.insert(cn: 'The Dark Knight') }.must_raise ROM::LDAP::OperationError

    # #insert returns true on success
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

    # confirmation
    accounts.where(uid: 'batman').one[:cn].must_equal ['The Dark Knight']

    # #update returns original dataset on failure
    accounts.where(uid: 'batman').update(missing: 'Hulk').must_equal [{
      dn: ['uid=batman,ou=users,dc=example,dc=com'],
      sn: ['Wayne'],
      appleimhandle: ['bruce-wayne'],
      cn: ['The Dark Knight'],
      objectclass: %w[
        top
        extensibleobject
        person
        organizationalPerson
        inetorgperson
        apple-user
      ],
      gidnumber: ['1050'],
      uidnumber: ['1003'],
      uid: ['batman']
    }]

    # #update returns original dataset on success
    accounts.where(uid: 'batman').update(sn: 'Stark').must_equal [{
      dn: ['uid=batman,ou=users,dc=example,dc=com'],
      sn: ['Wayne'],
      appleimhandle: ['bruce-wayne'],
      cn: ['The Dark Knight'],
      objectclass: %w[
        top
        extensibleobject
        person
        organizationalPerson
        inetorgperson
        apple-user
      ],
      gidnumber: ['1050'],
      uidnumber: ['1003'],
      uid: ['batman']
    }]

    # confirmation
    accounts.where(uid: 'batman').one[:sn].must_equal ['Stark']

    # #delete returns original dataset on success
    accounts.where(uid: 'batman').delete.must_equal [{
      dn: ['uid=batman,ou=users,dc=example,dc=com'],
      sn: ['Stark'],
      'apple-imhandle': ['bruce-wayne'],
      cn: ['The Dark Knight'],
      objectclass: %w[
        top
        extensibleobject
        person
        organizationalPerson
        inetorgperson
        apple-user
      ],
      gidnumber: ['1050'],
      uidnumber: ['1003'],
      uid: ['batman']
    }]

    # confirmation
    accounts.where(uid: 'batman').one.must_be_nil
  end

end
