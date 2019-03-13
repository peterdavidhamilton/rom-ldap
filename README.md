# ROM-LDAP

[![Coverage report](https://gitlab.com/peterdavidhamilton/rom-ldap/badges/master/coverage.svg?job=coverage)](gitlab.com/peterdavidhamilton/rom-ldap/coverage-ruby)

LDAP support for [rom-rb](https://github.com/rom-rb/rom).

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

[ROM-LDAP](https://gitlab.com/peterdavidhamilton/rom-ldap) is a [ROM](https://rom-rb.org) adapter for [LDAP](https://ldap.com) directories and provides a convenient query interface, type coercion and operational commands. Internally it uses [ldap-ber](https://gitlab.com/peterdavidhamilton/ldap-ber) which is a library of refinements to encode/decode Ruby primitives.

This project started life as a refactoring of the ["Net::LDAP for Ruby" (net-ldap)](https://github.com/ruby-ldap/ruby-net-ldap) gem. 




- Extracting the BER portion and convert from monkey patches to refinements.
- Handle attribute reformatting to enable attribute names to become valid method names.


<https://ldapwiki.com/wiki/Extended%20Flags>
<https://ldap.com/ldap-related-rfcs/>
<https://ldapwiki.com/wiki/RFC%20451r>


## ApacheDS LDAP Implementation

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

1. **Ladle**
  [Ladle](https://github.com/NUBIC/ladle) implements an embedded version of `apacheds`
  as a gem but suffers an unresolvable issue when attempting to delete an entry.



## Setup

Docker machine running RancherOS with the correct time.

    docker-machine ssh rancher "sudo date -u $(date -u +%m%d%H%M%Y)"
    docker-machine ssh rancher date -u


## Build

    docker build -t rom-ldap/apacheds
    docker run --name rom-ldap -d -p 389:10389 -p 636:10636 rom-ldap/apacheds:latest

## Demo

  - `$ bundle exec rake ldif[schema/wildlife]`
  - `$ bundle exec rake ldif[examples/animals]`
  - `$ bundle exec bin/demo`


# Overview

- Gateway
  
  - Relation
    Responsible for wrapping a dataset in a public api.
    
    - Dataset
      Inspired by Sequel gem and 
      Methods #add, #modify, #delete and query DSL methods like #equal and #unequal.
      Responsible for building an enumerable collection using chained criteria.
      Expresses criteria using an abstract-syntax tree.
      Uses parsers to convert from ldap filter strings to AST and back.
      Passes options to the directory instance.
      
      - Directory
        Responsible for receiving options from the dataset and communicating with the server through the connection instance.
        Returns responses as booleans or Entry objects.
        Methods #search and #find use #query internally; #add, #modify, #delete.
        
        - Entry
          Represents an directory entry as a hash-like object.
        
        - Connection
          Methods #add, #modify, #delete, #search, #bind
          Responsible for using BER refinements.
          Primarily uses #search which returns responses as PDU objects and yields entries to the directory.



`$ convert -size 1x1 xc:white pixel.jpg`
