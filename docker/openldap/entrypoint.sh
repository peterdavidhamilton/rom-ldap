#!/bin/sh


slapadd -l /etc/openldap/domain.ldif

# If docker-compose does not mount /var/run volume then ldapi:// will fail

slapd -d 256 \
  -f /etc/openldap/slapd.conf \
  -F /etc/openldap/slapd.d \
  -h "ldap:/// ldaps:/// ldapi://%2Fvar%2Frun%2Fldapi"
