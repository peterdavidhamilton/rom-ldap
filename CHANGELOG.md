# 0.0.13 / tbc

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



# 0.0.9 / 2018-12-07

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
