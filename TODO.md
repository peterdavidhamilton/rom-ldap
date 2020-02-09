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
    

6. **Associated relations - preload_assoc and transproc.**   
    Build LDAP to LDAP relation associations automatically.
    Simple rudimentary RDMS.
    <https://www.openldap.org/doc/admin24/intro.html#LDAP%20vs%20RDBMS>

7. **Rails integration**

8. Directory instrumentation using dry-monitor to replace debug logging

## ONGOING

- Improve Rspec coverage, currently 90% complete @ v0.1.0
- Improve Yard docs, currently 72% complete @ v0.1.0, see tmp/undocumented.txt
- Ensure Rubocop style compliance