# ROM-LDAP

[![pipeline status][pipeline]][branch] [![coverage report][coverage]][branch]


[ROM-LDAP][rom-ldap] is a [ROM][rom-rb] adapter for [LDAP][ldap] and provides lightweight directory object mapping for Ruby.
This gem makes it easier to use LDAP in your project or even as your primary datastore and an alternative to back-ends like MongoDB or CouchDB.



## Requirements

[ROM-LDAP][rom-ldap] is compatible with versions of [Ruby][ruby] from 2.4 to 2.7.



## History

This project has evolved from a refactoring of the [net-ldap][net-ldap] gem and tries to emulate the functionality of
[rom-sql][rom-sql] which is itself backed by the [sequel][sequel] gem.


A more detailed walk-through of [rom-ldap][rom-ldap] can be found at [pdhamilton.uk][pdhamilton].

## Installation

Add this line to your Gemfile:

```ruby
gem 'rom-ldap'
```


#### Configuration

To configure a gateway connection to an LDAP server you can use environment variables or pass in a URI:

```ruby

config = ROM::Configuration.new(:ldap, 'ldap://cn=admin,dc=rom,dc=ldap:topsecret@openldap')

ENV['LDAPURI'] = 'ldap://cn=admin,dc=rom,dc=ldap:topsecret@openldap'

config = ROM::Configuration.new(:ldap)

rom = ROM.container(config)

directory = ROM.container(config).directory

=> #<ROM::LDAP::Directory
    uri='ldap://cn=admin,dc=rom,dc=ldap:topsecret@openldap'
    vendor='OpenLDAP'
    version='0.0' />

```

#### Extensions

For the greatest compatibility with Ruby method naming you can pass the optional "compatibility" extension whilst configuring the gateway.
This will format the attributes of directory entries into names suitable for ruby methods by converting _camelCase_ and _kebab-case_ to _snake_case_.

```ruby
config = ROM::Configuration.new(:ldap, extensions: [:compatibility])
```

The `ROM::LDAP::Relation` class already has support for exporting to `JSON`, `YAML` and `LDIF`.
Other extensions are available including exporting to `DSML` format.

```ruby
config = ROM::Configuration.new(:ldap, extensions: [:dsml_export]) do |conf|
  conf.relation(:all) { schema('(cn=*)', infer: true) }
end

rom = ROM.container(config)

rom.relations[:all].to_dsml
```




## LDAP Servers

The project has docker provision for four opensource LDAP servers to test against;
see `spec/fixtures/vendors.yml` for connection details.
Allow the dependent services to boot before running the specs in the gem container.

    $ cd docker
    $ docker-compose up -d apacheds openldap 389ds opendj
    $ docker-compose up rom


1. _[ApacheDS][apacheds]_ is an extensible and embeddable directory server entirely written in Java.

2. _[OpenLDAP][openldap]_ is a high performance replacement for Oracle Corporation's Berkeley DB.
  It is mostly written in C and its functionality can be extended with additional modules.

3. _[389DS][389ds]_ from the Fedora Project is also written in Java.

4. _[OpenDJ][opendj]_ Community Edition from the Open Identity Platform is written in Java.


A custom schema is loaded into each of the servers and defines attribute types and object classes used
in the tests and [examples](#examples).


## Seed Data

_[Apache Directory Studio][apachestudio]_ is a cross-platform platform LDAP management application with a graphic interface.
For convenience, you can import the predefined connection settings for the docker environment using the included file
`spec/fixtures/vendors.lbc`.

Alternatively, if you have the `ldapmodify` command installed on your development machine,
you can use a rake task to import a folder of LDIF files:

    $ LDAPURI=ldap://localhost:4389 \
      LDAPBINDDN='cn=Directory Manager' \
      LDAPBINDPW=topsecret \
      LDAPDIR=./examples/ldif \
      rake ldap:modify

Or, you could import the _1000_ example users included with this project, with no dependency on other software.
The `DEBUG` variable will print to screen any response from the server that would normally be logged.

    $ DEBUG=y \
      LDAPURI='ldap://cn=Directory Manager:topsecret@localhost:4389' \
      rake 'ldif:import[examples/ldif/users.ldif]'


## Examples

The console script connects and loads [Pry][pry] so you can explore your directory on the command line.

    $ ./bin/console

To see a demonstration in action you can explore the examples after loading the seed data.

    $ rake 'ldif:import[examples/ldif/animals.ldif]'

    $ ./examples/fauna.rb

Check out _[Fauna][fauna]_ which is a more complete version of the example above and models data on evolutionary taxonomy.

If you use _[Rails][rails]_ then try the _[rom-ldap-rails][rom-ldap-rails]_ repository,
for a skeleton version of this same example applied to the [Ruby on Rails][rails] framework.






[389ds]: https://www.port389.org
[apacheds]: http://directory.apache.org/apacheds/downloads
[apachestudio]: http://directory.apache.org/studio/downloads
[branch]: https://gitlab.com/peterdavidhamilton/rom-ldap/commits/master
[coverage]: https://gitlab.com/peterdavidhamilton/rom-ldap/badges/master/coverage.svg
[fauna]: https://gitlab.com/peterdavidhamilton/fauna
[ldap-ber]: https://gitlab.com/peterdavidhamilton/ldap-ber
[ldap]: https://ldap.com
[net-ldap]: https://github.com/ruby-ldap/ruby-net-ldap
[opendj]: https://www.openidentityplatform.org/opendj
[openldap]: http://www.openldap.org
[pdhamilton]: https://pdhamilton.uk/projects/rom-ldap
[pipeline]: https://gitlab.com/peterdavidhamilton/rom-ldap/badges/master/pipeline.svg
[pry]: http://pryrepl.org
[rails]: https://rubyonrails.org
[rom-ldap-rails]: https://gitlab.com/peterdavidhamilton/rom-ldap-rails
[rom-ldap]: https://gitlab.com/peterdavidhamilton/rom-ldap
[rom-rb]: https://rom-rb.org
[rom-sql]: https://rom-rb.org/5.0/learn/sql
[ruby]: https://www.ruby-lang.org/en/downloads
[sequel]: http://sequel.jeremyevans.net
