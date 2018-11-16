# ROM LDAP Adapter

ROM-LDAP is a ROM adapter for LDAP directories and provides a convenient query interface,
type coercion and operational commands. Internally it uses [ldap-ber](https://github.com/mrpeterpeter/ldap-ber)
which is a library of refinements to encode/decode Ruby primitives.

This project started life as a rewrite of the [net-ldap]() gem.


<https://ldap.com/ldap-related-rfcs/>
<https://ldapwiki.com/wiki/RFC%20451r>


Server Implementations:

1. **Apache DS**
  [ApacheDS](http://directory.apache.org/apacheds/downloads) is an extensible and
  embeddable directory server entirely written in Java, which has been certified LDAPv3
  compatible by the Open Group.

1. **Apache Directory Studio**
  [Apache Directory Studio](http://directory.apache.org/studio/downloads) is a
  complete directory tooling platform intended to be used with any LDAP server
  however it is particularly designed for use with the ApacheDS.

1. **Ladle**
  [Ladle](https://github.com/NUBIC/ladle) implements an embedded version of `apacheds`
  as a gem but suffers an unresolvable issue when attempting to delete an entry.

1. **Containerised ApacheDS**
  The test suite uses a containerised version of `apacheds`. Forked from OpenMicroscopy.
