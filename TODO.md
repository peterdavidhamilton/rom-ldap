# TODO

1. **Time out limit and retry in client.**
    Test timeout expiration and retry in client methods.

2. **SSL connections.**
    Hand secure connections; also some vendors only permit certain functions through a secure connection.

3. **Rouge lexer for LDAP filters.**
    Custom terminal syntax for LDAP similar to rom-sql.

4. **Paged results.**
    Use a real paged request instead of chunking all results

5. **Transactions.**
    Rollback failed actions on compatible LDAP servers.
    <https://www.port389.org/docs/389ds/design/exop-plugin-transactions.html>

6. **Associated relations - preload_assoc and transproc.**
    Build LDAP to LDAP relation associations automatically.
    Simple rudimentary RDMS.
    <https://www.openldap.org/doc/admin24/intro.html#LDAP%20vs%20RDBMS>

7. **Logging**
   Directory instrumentation using dry-monitor to replace debug logging.

8. **ROM-RB**
   Keep pace with other rom-rb improvements like `rom/devtools` integration.

9. **CI/CD**
   Speed up testing by only using OpenLDAP, with other vendors as optional extras (including Microsoft AD LDS).

## ONGOING

- Improve Rspec coverage, currently 90% complete @ v0.2.3
- Improve Yard docs, currently 76% complete @ v0.2.3
- Ensure Rubocop style compliance
