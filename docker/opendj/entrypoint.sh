#!/bin/bash -e

LDAP_PORT=${LDAP_PORT:-389}
LDAPS_PORT=${LDAPS_PORT:-636}


if [[ $(/opt/opendj/bin/status) == *"not configured"* ]]; then
  echo "Running OpenDJ setup...."

  LDIF_FILE=/ldif/domain.ldif

  /opt/opendj/setup \
    --cli \
    --verbose \
    --hostname $HOSTNAME \
    --ldapPort $LDAP_PORT \
    --ldapsPort $LDAPS_PORT \
    --baseDN "$BASE_DN" \
    --enableStartTLS \
    --generateSelfSignedCertificate \
    --rootUserDN "$ROOT_USER_DN" \
    --rootUserPassword "$ROOT_PASSWORD" \
    --acceptLicense \
    --no-prompt \
    --doNotStart \
    --ldifFile $LDIF_FILE
    # --ldifFile /ldif/wildlife.ldif

  /opt/opendj/bin/start-ds --systemInfo

  /opt/opendj/bin/status
fi

echo "Starting OpenDJ server...."
/opt/opendj/bin/start-ds --nodetach
# \
#   && tail -f /opt/opendj/logs/access
