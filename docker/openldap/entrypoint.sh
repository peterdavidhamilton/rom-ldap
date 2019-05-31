#!/bin/bash -e
#
# log levels
#
#   -1    enable all debugging
#   0     no debugging
#   1     trace function calls
#   2     debug packet handling
#   4     heavy trace debugging
#   8     connection management
#   16    print out packets sent and received
#   32    search filter processing
#   64    configuration file processing
#   128   access control list processing
#   256   stats log connections/operations/results
#   512   stats log entries sent
#   1024  print communication with shell backends
#   2048  print entry parsing debugging

ulimit -n 1024

LDAP_LOG_LEVEL=${LDAP_LOG_LEVEL:-256}
LDAP_BACKEND=${LDAP_BACKEND:-mdb}

if [ ! -d "/var/lib/ldap/data.mdb" ]; then

  echo "Configuring OpenLDAP server..."

  chown -R openldap:openldap /var/lib/ldap
  chown -R openldap:openldap /etc/ldap

  rm -R /var/backups

  cat <<EOF | debconf-set-selections
slapd slapd/internal/generated_adminpw password ${LDAP_ADMIN_PASSWORD}
slapd slapd/internal/adminpw password ${LDAP_ADMIN_PASSWORD}
slapd slapd/password2 password ${LDAP_ADMIN_PASSWORD}
slapd slapd/password1 password ${LDAP_ADMIN_PASSWORD}
slapd slapd/domain string ${LDAP_DOMAIN}
slapd shared/organization string ${LDAP_ORGANISATION}
slapd slapd/backend string ${LDAP_BACKEND^^}
slapd slapd/purge_database boolean true
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/no_configuration boolean false
slapd slapd/dump_database select when needed
EOF

  dpkg-reconfigure -f noninteractive slapd

  echo "Testing OpenLDAP server..."

  /usr/sbin/slaptest
fi

echo "Starting OpenLDAP server..."

# usage: slapd options
#         -4              IPv4 only
#         -6              IPv6 only
#         -T {acl|add|auth|cat|dn|index|passwd|test}
#                         Run in Tool mode
#         -c cookie       Sync cookie of consumer
#         -d level        Debug level
#         -f filename     Configuration file
#         -F dir  Configuration directory
#         -g group        Group (id or name) to run as
#         -h URLs         List of URLs to serve
#         -l facility     Syslog facility (default: LOCAL4)
#         -n serverName   Service name
#         -o <opt>[=val] generic means to specify options; supported options:
#                 slp[={on|off|(attrs)}] enable/disable SLP using (attrs)
#         -r directory    Sandbox directory to chroot to
#         -s level        Syslog level
#         -u user         User (id or name) to run as
#         -V              print version info (-VV exit afterwards, -VVV print
#                         info about static overlays and backends)
#
/usr/sbin/slapd \
  -h "ldap://$HOSTNAME ldaps://$HOSTNAME ldapi:///" \
  -u openldap \
  -g openldap \
  -d $LDAP_LOG_LEVEL
