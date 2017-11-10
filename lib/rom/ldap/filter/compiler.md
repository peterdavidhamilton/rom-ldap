# Filter AST Compiler

## AND Operation

``(& (...K1...) (...K2...))
(& (...K1...) (...K2...) (...K3...) (...K4...))

## OR Operation

``(| (...K1...) (...K2...))
(| (...K1...) (...K2...) (...K3...) (...K4...))


## Nested Operation

Every AND/OR operation can also be understood as a single criterion:

``(|(& (...K1...) (...K2...))(& (...K3...) (...K4...)))

means: (K1 AND K2) OR (K3 AND K4)



## Special Characters

`( ) & | = ! > < ~ * / \`

The search criteria consist of a requirement for an LDAP attribute, e.g. (givenName=Sandra).
Following rules should be considered:

Boolean:
  => `(attribute=TRUE)`
  => `(attribute=FALSE)`

Equality:
  => `(attribute=abc)`
  => `(&(objectclass=user)(displayName=Foeckeler)`

Negation:
  => `(!(attribute=abc))`
  => `(!objectClass=group)`

Presence:
  => `(attribute=*)`
  => `(mailNickName=*)`

Absence:
  => `(!(attribute=*))`
  => `(!proxyAddresses=*)`

Greater than:
  => `(attribute>=abc)`
  => `(mdbStorageQuota>=100000)`

Less than:
  => `(attribute<=abc)`
  => `(mdbStorageQuota<=100000)`

# ~= is treated as = in ActiveDirectory
Proximity:
  => `(attribute~=abc)`
  => `(displayName~=Foeckeler)`

Wildcards:
  => `(sn=F*)`
  => `(mail=*@cerrotorre.de)`
  => `(givenName=*Paul*)`
