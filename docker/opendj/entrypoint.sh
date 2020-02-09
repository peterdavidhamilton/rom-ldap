#!/bin/bash -e

LDAP_PORT=${LDAP_PORT:-389}
LDAPS_PORT=${LDAPS_PORT:-636}


if [[ $(/opt/opendj/bin/status) == *"not configured"* ]]; then

  # https://github.com/OpenIdentityPlatform/OpenDJ/issues/53
  # Requires 5GB of free space
  echo "Configuring OpenDJ server..."

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

  /opt/opendj/bin/start-ds --systemInfo

  echo "Testing OpenDJ server..."

  /opt/opendj/bin/status
fi

echo "Starting OpenDJ server...."

/opt/opendj/bin/start-ds --nodetach

tail -F /opt/opendj/logs/error