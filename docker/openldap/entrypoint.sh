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

# if [[ $(/usr/sbin/slaptest) == *"not configured"* ]]; then
# if no backups exist
# if [ -z "$(ls -A /var/backups/slapd*)" ]; then
# if [ ! -f /.done ]; then

  echo "Configuring OpenLDAP server..."

  LDAP_LOG_LEVEL=${LDAP_LOG_LEVEL:-256}
  LDAP_BACKEND=${LDAP_BACKEND:-mdb}

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

#   if [[ $(/usr/sbin/slaptest) == *"succeeded"* ]]; then
#     echo "set up complete"
#     touch /.done
#   fi
# fi

echo "Starting OpenLDAP server..."

/usr/sbin/slapd \
  -h "ldap://$HOSTNAME ldaps://$HOSTNAME ldapi:///" \
  -u openldap \
  -g openldap \
  -d $LDAP_LOG_LEVEL
