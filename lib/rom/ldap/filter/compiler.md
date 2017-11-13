# Current net-ldap flow

1. dataset uses dsl to chain queries
1. dsl constructs a filter using expression
1. relation -> dataset -> dsl -> expression : forwarded methods to build filter expression
1. directory:operations.query passes options to connection.search
1. connection.search uses filter:parser.call
1. filter:parser.call returns an expression object
1. connection.search then calls .to_ber on the expression
1. to_ber is provided by ber:convertor.call which works recursively
1. connection.search submits encoded object to server


# replacement

1. dataset builds ast instead of criteria
1. directory.query receives an ast value object
1. directory calls filter.decomposer to build nested expression objects
1. connection.search then calls .to_ber on the expression
1. to_ber is provided by expression:encoder.call which works recursively
1. connection.search submits encoded object to server

## summary of propsed changes

move ber:convertor and ber:parser into rom-ldap
dsl is redundant
dataset chains ast together
filter.decomposer uses ast to build nested expressions
new expression#to_a method spits out the three parts



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

# ~= (approx) is treated as = (equals) in ActiveDirectory
Proximity:
  => `(attribute~=abc)`
  => `(displayName~=Foeckeler)`

Wildcards:
  => `(sn=F*)`
  => `(mail=*@cerrotorre.de)`
  => `(givenName=*Paul*)`
