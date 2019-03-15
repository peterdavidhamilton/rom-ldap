# ROM-LDAP

[![pipeline status](https://gitlab.com/peterdavidhamilton/rom-ldap/badges/develop/pipeline.svg)](https://gitlab.com/peterdavidhamilton/rom-ldap/commits/develop)

[![coverage report](https://gitlab.com/peterdavidhamilton/rom-ldap/badges/develop/coverage.svg)](https://gitlab.com/peterdavidhamilton/rom-ldap/commits/develop)

LDAP support for [rom-rb][rom-rb].

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rom-ldap'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rom-ldap

## History

[ROM-LDAP][rom-ldap] is a [ROM][rom-rb] adapter for [LDAP][ldap] directories and provides a convenient query interface, type coercion and operational commands. Internally it uses [ldap-ber][ldap-ber] which is a library of refinements to encode/decode Ruby primitives.

This project started life as a refactoring of the [`Net::LDAP` (net-ldap)][net-ldap] gem. 

- Extracting the BER portion and convert from monkey-patching to refinements.
- Handle LDAP entry attribute reformatting to be valid Ruby method names.


[ldap-ber]: https://gitlab.com/peterdavidhamilton/ldap-ber
[ldap]: https://ldap.com
[net-ldap]: https://github.com/ruby-ldap/ruby-net-ldap
[rom-ldap]: https://gitlab.com/peterdavidhamilton/rom-ldap
[rom-rb]: https://rom-rb.org



## Setup

Docker machine running RancherOS with the correct time.

    docker-machine ssh rancher "sudo date -u $(date -u +%m%d%H%M%Y)"
    docker-machine ssh rancher date -u

### ApacheDS LDAP Implementation

1. **Containerised ApacheDS**
  The test suite uses a containerised version of `apacheds`. 

1. **Apache DS**
  [ApacheDS](http://directory.apache.org/apacheds/downloads) is an extensible and
  embeddable directory server entirely written in Java, which has been certified LDAPv3
  compatible by the Open Group.

1. **Apache Directory Studio**
  [Apache Directory Studio](http://directory.apache.org/studio/downloads) is a
  complete directory tooling platform intended to be used with any LDAP server
  however it is particularly designed for use with the ApacheDS.


## Build

    docker build -t rom-ldap/apacheds
    docker run --name rom-ldap -d -p 389:10389 -p 636:10636 rom-ldap/apacheds:latest

## Demo

  - `$ rake ldif[schema/wildlife]`
  - `$ rake ldif[examples/animals]`
  - `$ bin/demo`
