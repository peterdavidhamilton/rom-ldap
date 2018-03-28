# README

A demonstration of rom-ldap using biological classification and taxonomic hierarchy as an example dataset.

- `$ cd rom-ldap/examples`
- `$ bundle package --all`
- `$ rake ldif[../../examples/ldif/schema]`
- `$ rake ldif[../../examples/ldif/animals]`
- `$ bundle exec ruby ./examples/life.rb`
