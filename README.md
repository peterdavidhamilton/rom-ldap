# ROM LDAP Adapter

## Introduction

ROM-LDAP is an adapter for LDAP directories and provides a convenient query interface,
type coercion and operational commands. Internally it uses ldap-ber which is a rewrite of
core code from the net-ldap gem and a refactored version of net-ldap connection class.

## Test Options

- *host:* '127.0.0.1'
- *port:* '10389'
- *base:* 'cn=users,dc=example,dc=com'

## Development

Server Implementations:

1. **OpenLDAP**
    [http://www.openldap.org/]

1. **Microsoft Active Directory**

1. **Apple Open Directory**

1. **Novell eDirectory**

1. **Red Hat Directory Server**

1. **Apache DS**
    [ApacheDS](http://directory.apache.org/apacheds/downloads) is an extensible and embeddable directory server entirely written in Java, which has been certified LDAPv3 compatible by the Open Group.
    - Start server:
      `$ apacheds start default`
    - Seed server:
      `$ ldapmodify -h 127.0.0.1 -p 10389 -D "uid=admin,ou=system" -w secret -a -f ./spec/support/setup.ldif`

1. **Apache Directory Studio** (development only)
    [Apache Directory Studio](http://directory.apache.org/studio/downloads) is a complete directory tooling platform intended to be used with any LDAP server however it is particularly designed for use with the ApacheDS.

1. **Ladle** (development only)
    [Ladle](https://github.com/NUBIC/ladle) implements an embedded version of `apacheds` as a gem but suffers an unresolvable issue when attempting to delete an entry.


## TODO

- Make test suite more fun with custom data and schemas.
- Add missing specs, clone from rom-sql.
- Fix gte and lte operations.
- Tidy functions to employ chaining more methods.
