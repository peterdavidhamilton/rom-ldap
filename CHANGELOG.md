## unreleased

<!-- TODO -->
[Compare v0.2.1...master](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.2.0...master)


# 0.2.1 / 2021-02-xx

### Fixed

- Replace use of deprecated URI.encode/decode method for compatibility with Ruby v2.7. [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/   )
- Fix DSML export of an entry with `ObjectClasses` omitted.
- Correct misnamed error classes raise by the directory.
- Remove old development code and a general tidy up.
- Run more specs against all four test LDAP vendors
- Restrict `gemspec` to Ruby version 2, preventing keyword params errors when running v3.
- Fix ApacheDS docker container state contamination between loads.

### Changed

- Replace current year on license.
- Simplify `docker-compose.yml` and `gitlab-ci.yml` removing deprecated ENV vars.
- Build docker images with custom schema preloaded.
- Update specs for testing ordering against OpenLDAP with the `sssvlv` overlay module.
- Remove volumes for LDAP vendors in `docker-compose.yml`.
- Remove rom-ldap rake tasks from the gem Rakefile and only load in the examples folder.
- Remove comparison of total entries from `ldif:import` task as this is dependent on the connection using the correct base, the same as the entries being imported.
- Simplify the `gemspec` dependencies.


## Added

- Add missing Style/FrozenStringLiteralComment lines.
- Add spec for ldap unix socket connections.
- Add extension for using the [OJ](http://www.ohler.com/oj/) gem.
- Add attribute ordering to the custom wildlife schema attributes.
- Allow the `DEFAULT_VENDOR` environment variable to change the default vendor used in a spec.


[Compare v0.2.0...v0.2.1](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.2.0...0.2.1)



# 0.2.0 / 2020-03-08

### Changed

- Move LDIF for specs under fixtures folder
- Make the 'people' factory in specs usable by all vendors by dropping the non-standard attribute apple-imhandle
- Deleted non-ldap related methods like #qualified
- Internal parsing of query strings and abstract criteria
- Type mapping from oid to ruby classes
- `Dry::Transformer` replaces `Transproc`
- Update to dry-types 1.2
- Make switching between vendors easier by replacing vendor-specific extensions with reloadable module injection [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/04e828a9c327fadd0829839903e3953c5709ac0a)
- Folder structure for vendor specific code [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/04e828a9c327fadd0829839903e3953c5709ac0a)
- Simplify parsing as functions from string > ast > expression [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/0a71e469fe9f13cec9a2d111d5f2814e6c490dae)

### Fixed

- Allow username and password inside uri
- Handle IPV6 loopback addresses so localhost can be used
- Test suite readability against all four vendors
- Make running specs easier inside and outside of a docker environment with URI switching based on the context in which the suite is run
- Running specs inside Docker
- Rubocop errors
- Gitlab CI/CD pipeline
- Projected tuple attributes
- Renamed tuple attributes [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/c0670d38b866d28afba94fddd34fddb7df8d5d23)
- Ordering results
- Building deeply nested expression queries [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/0a71e469fe9f13cec9a2d111d5f2814e6c490dae)

### Added

- Implement the tree control in the client delete method making deletion of entries with children more efficient
- Gateway configuration using ENV VARS
- LDIF import functionality as rake task
- Generating fixtures to LDIF using factories and `relation#to_ldif`
- Missing query operators used inside `relation#where` blocks
- Raw filter string parsing inside `relation#where` blocks
- Extra OIDs

[Compare v0.1.0...v0.2.0](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.1.0...0.2.0)



# 0.1.0 / 2019-03-15

### Changed

- [BREAKING] rom-core (4.2.1) depends upon dry-types (0.15.0) which is only supported by ruby 2.4 and above. Change minimum supported version to 2.4

### Fixed

- Use [Semantic Versioning](https://semver.org/) from now on, however changing the Ruby version dependency should constitute a MAJOR change, we are not yet ready for the public 1.0.0 release

[Compare v0.1.0...v0.0.14](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.1.0...v0.0.14)



# 0.0.14 / 2019-03-15

### Added

- Draft `dry-monitor` LDAP logger [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/018dbd51b1d675b3153d8ec1d12a2a1f0416243b)

### Changed

- Remove Struct convenience class [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/0c151d6aac915094a85096b40269efbe9099d042)


[Compare v0.0.13...v0.0.14](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.13...v0.0.14)



# 0.0.13 / 2019-03-14

### Added

- Docker setup [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/7b08f6f69b9fa39a9700b45b72d91fe094a3442b)
- `CHANGELOG.md` [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/0731b6a467fd97a4769f9bc481a2975f0638b1b9)
- New `ROM::LDAP::Relation` methods #to_dsml and #to_msgpack [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/cc9d250584ba8cf3e875f7aa0f3754f676fdf2db)
- Introduce `ROM::LDAP::RestrictionDSL` from rom-sql
[#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/f0ddfe6a062fd63c1d6ab305d2cc97c50abf170d)
- Prepare connection variables using `ROM::LDAP::Directory::ENV` [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/bbe8c8d07db0fe7daedff0921d4f11f9eacf374d)
- Add `ROM::LDAP::Dataset` reverse functionality [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/c03d52e4a71764d0d44255367cbee17b786fd4e6)

### Changed

- Improve `ROM::LDAP::Dataset` param validation and defaults [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/c03d52e4a71764d0d44255367cbee17b786fd4e6)
- [BREAKING] Use LDAPURI (`'ldap://127.0.0.1:389'`) to initialise a `ROM::LDAP::Gateway` [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/55072ce9640b3cc736f05753d9b6c3b48ea64b85)
- Replace `Net::TCPClient` dependency with `ROM::LDAP::Client` and handle new URI connection params [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/33962e2ad6db42c29bc3e4e515469d560ca17c68)

### Fixed

- `ROM::LDAP::Gateway` now accepts extenions and has no responsibility for creating a connection [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/55072ce9640b3cc736f05753d9b6c3b48ea64b85)
- `ROM::LDAP::Directory::Entry` can be tested like a hash in specs using #include [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/5868646492f0ff1c4e88185c8221e3f95837b0c6)


[Compare v0.0.12...v0.0.13](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.12...v0.0.13)






# 0.0.12 / 2018-10-23

### Added

- Missing `bin/console` and `bin/setup` scripts added [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/621fcc2280564114edbe9c3acba4e344a9814436)

### Changed

- Compatible with Ruby >= 2.3 [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/621fcc2280564114edbe9c3acba4e344a9814436)
- Improve demo fixtures and add new study attribute to explore joins [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/673f933baacaf31e077b8cfd26064ea92d418849)

### Fixed

- Rubocop warnings [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/8a6620dd170e1a63fa6eda923f0a09ade02d9808)


[Compare v0.0.11...v0.0.12](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.11...v0.0.12)



# 0.0.11 / 2018-03-27


### Fixed

- `ROM::LDAP::Directory#delete` now returns the deleted tuple [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/6d5438c502406f1ed36bbe30e46f18ec2be413de)


[Compare v0.0.10...v0.0.11](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.10...v0.0.11)



# 0.0.10 / 2018-03-02

### Added

- `ROM::LDAP::Dataset#shuffle` [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/2fce12f854cce4fdd4a7f6758bbf54b1f23cefa2)

### Fixed

- `ROM::LDAP::Directory` now identifies Microsoft Active Directory [#ref](https://gitlab.com/peterdavidhamilton/rom-ldap/commit/d6729beb894f45eb8bf0fcd3d49f4e16ba33dfc1)

[Compare v0.0.9...v0.0.10](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.9...v0.0.10)



# 0.0.9 / 2017-12-07

[Compare v0.0.8...v0.0.9](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.8...v0.0.9)



# 0.0.8 / 2017-11-25

[Compare v0.0.7...v0.0.8](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.7...v0.0.8)



# 0.0.7 / 2017-11-02

[Compare v0.0.6...v0.0.7](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.6...v0.0.7)



# 0.0.6 / 2017-10-18

[Compare v0.0.5...v0.0.6](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.5...v0.0.6)



# 0.0.5 / 2017-06-28

[Compare v0.0.4...v0.0.5](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.4...v0.0.5)



# 0.0.4 / 2017-06-21

[Compare v0.0.3...v0.0.4](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.3...v0.0.4)



# 0.0.3 / 2017-03-24

[Compare v0.0.2...v0.0.3](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.2...v0.0.3)



# 0.0.2 / 2017-01-23

[Compare v0.0.1...v0.0.2](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.1...v0.0.2)



# 0.0.1 / 2016-07-18

[Compare v0.0.0...v0.0.1](https://gitlab.com/peterdavidhamilton/rom-ldap/compare/v0.0.0...v0.0.1)





# 0.0.0 / 2016-07-17

Initial Commit.
