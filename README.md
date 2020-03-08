# ROM-LDAP

[![pipeline status][pipeline]][branch] [![coverage report][coverage]][branch]


[ROM-LDAP][rom-ldap] is a [ROM][rom-rb] adapter for [LDAP][ldap]. 
Internally it uses [ldap-ber][ldap-ber] which is a library of refinements to 
encode Ruby primitives.

LDAP can be used as a structured NoSQL server

## Requirements

[ROM-LDAP][rom-ldap] requires [Ruby 2.4.0][ruby] or greater.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rom-ldap'
```

And then execute:

```bash
$ bundle
```

Or install it yourself as:

```bash
$ gem install rom-ldap
```



## Usage

*Lightweight Directory Access Protocol* (LDAP) support for [rom-rb][rom-rb].

#### Configuration

To configure a gateway connnection to an LDAP server use:

```ruby
config = ROM::Configuration.new(:ldap, 'ldap://cn=admin,dc=rom,dc=ldap:topsecret@openldap')

rom = ROM.container(config).directory
# => #<ROM::LDAP::Directory 
#     uri='ldap://cn=admin,dc=rom,dc=ldap:topsecret@openldap' 
#     vendor='OpenLDAP' version='0.0' />
```

If the URI is omitted, then environment variables can be used to set the connection. 
With no variables the connection will default to a local connection on port *389*.

```ruby
ENV['LDAPURI'] = 'ldaps://cn=admin,dc=rom,dc=ldap:topsecret@openldap'

config = ROM::Configuration.new(:ldap)

rom = ROM.container(config)
```

#### Extensions

For the greatest compatibility with Ruby method naming you can pass the optional 
"compatibility" extension whilst configuring the gateway.
This will format the attributes of directory entries into names more suitable 
for ruby by converting **"camelCase"** and **"hyphen-ated"** to **"snake_case"**.

```ruby
config = ROM::Configuration.new(:ldap, nil, extensions: [:compatibility])
```

The `ROM::LDAP::Relation` class already has support for exporting to `JSON`, 
`YAML` and `LDIF`. Other extensions are available including exporting to `DSML` format. 

```ruby
config = ROM::Configuration.new(:ldap, nil, extensions: [:dsml_export]) do |conf|
  conf.relation(:all) { schema('(cn=*)', infer: true) }
end

rom = ROM.container(config)

rom.relations[:all].to_json
rom.relations[:all].to_yaml
rom.relations[:all].to_ldif
rom.relations[:all].to_dsml
```




## Docker

The project has docker provision for four opensource entrprise class LDAP servers 
test against; see `spec/fixtures/vendors.yml` for connection details.

```bash
$ cd docker
$ docker-compose up -d apacheds openldap 389ds opendj
$ docker-compose up rom
```

#### Containers

1. **[ApacheDS][apacheds]** is an extensible and embeddable directory server 
  entirely written in Java, which has been certified LDAPv3 compatible by the 
  Open Group. The JDBM backend is fast at retreiving data but slow writing to 
  disk. 
  **[Apache Directory Studio][apachestudio]** is a complete directory tooling 
  platform intended to be used with any LDAP server however it is particularly 
  designed for use with the ApacheDS.  
  You can import the vendor connection details into Apache Directory Studio using 
  `spec/fixtures/vendors.lbc`.

2. **[OpenLDAP][openldap]** is a high performance replacement for Oracle 
  Corporation's Berkeley DB. 

3. **[389DS][389ds]** from the Fedora Project.
  

4. **[OpenDJ][opendj]** Community Edition is an LDAPv3 compliant directory service 
  written in Java from the Open Identity Platform.

#### Schema

A custom themed **wildlife** schema is loaded into [ApacheDS][apacheds] automatically 
but can also be loaded into [OpenDJ][opendj] and [389DS][389ds]. 
Experimentation shows these are around 25 times faster than Apache in this 
environment when working with large datasets.

If you have the `ldapmodify` command on your development machine you can use the 
following rake task to load the changes:

```bash
$ LDAPURI=ldap://localhost:4389 \
  LDAPBINDDN='cn=Directory Manager' \
  LDAPBINDPW=topsecret \
  LDAPDIR=./spec/fixtures/ldif \
  rake ldap:modify`
```

You can also import 1000 example users with no dependency on local commands:

```bash
$ DEBUG=y \
  LDAPURI='ldap://cn=Directory Manager:topsecret@localhost:4389' \
  rake 'ldif:import[spec/fixtures/ldif/examples/users.ldif]'
```





## Examples

```bash
$ ./bin/console
```

The console connects and loads [Pry][pry]

To see a demonstration try `./examples/fauna.rb` after loading `animals.ldif`: 

```bash
$ LDAPURI='ldap://uid=admin,ou=system:secret@localhost:1389' \
  rake 'ldif:import[spec/fixtures/ldif/examples/animals.ldif]'
```

**[Fauna][fauna]** is a demo of [ROM-LDAP][rom-ldap] based on evolutionary taxonomy.






## History

This project began as an attempt at using the [net-ldap][net-ldap] gem to create 
a new adapter for [ROM][rom-rb]. Eventually it was refactored and removed the 
[net-ldap][net-ldap] dependency, extracting the BER portion and using refinements 
instead of monkey-patching the standard library.

Thank you...




[389ds]: https://www.port389.org
[apacheds]: http://directory.apache.org/apacheds/downloads
[apachestudio]: http://directory.apache.org/studio/downloads
[branch]: https://gitlab.com/peterdavidhamilton/rom-ldap/commits/develop
[coverage]: https://gitlab.com/peterdavidhamilton/rom-ldap/badges/develop/coverage.svg
[fauna]: https://gitlab.com/peterdavidhamilton/fauna
[ldap-ber]: https://gitlab.com/peterdavidhamilton/ldap-ber
[ldap]: https://ldap.com
[net-ldap]: https://github.com/ruby-ldap/ruby-net-ldap
[opendj]: https://www.openidentityplatform.org/opendj
[openldap]: http://www.openldap.org
[pipeline]: https://gitlab.com/peterdavidhamilton/rom-ldap/badges/develop/pipeline.svg
[pry]: http://pryrepl.org/
[rom-ldap]: https://gitlab.com/peterdavidhamilton/rom-ldap
[rom-rb]: https://rom-rb.org
[ruby]: https://www.ruby-lang.org/en/downloads/