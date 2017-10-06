# ROM LDAP Adapter

## Test Options

- *host:* '127.0.0.1'
- *port:* '10389'
- *base:* 'cn=users,dc=example,dc=com'

## Development

Server choices:

1. **Apache Directory Studio**
    [Apache Directory Studio](http://directory.apache.org/studio/downloads) is a complete directory tooling platform intended to be used with any LDAP server however it is particularly designed for use with the ApacheDS.

2. **Apache DS**
    [ApacheDS](http://directory.apache.org/apacheds/downloads) is an extensible and embeddable directory server entirely written in Java, which has been certified LDAPv3 compatible by the Open Group.
    - Start server:
      `$ apacheds start default`
    - Seed server:
      `$ ldapmodify -h 127.0.0.1 -p 10389 -D "uid=admin,ou=system" -w secret -a -f ./spec/support/setup.ldif`


3. **Ladle**
    [Ladle](https://github.com/NUBIC/ladle) implements an embedded version of `apacheds` as a gem but suffers an unresolvable issue when attempting to delete an entry.


