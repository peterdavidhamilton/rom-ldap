#!/bin/bash -e
#
# log levels
#
#   1       Trace function calls
#   2       Debug packet handling
#   4       Heavy trace output debugging
#   8       Connection management
#   16      Print out packets sent/received
#   32      Search filter processing
#   64      Config file processing
#   128     Access control list processing (very detailed!)
#   2048    Log entry parsing
#   4096    Housekeeping thread
#   8192    Replication debugging
#   16384   Critical messages
#   32768   Database cache debugging
#   65536   Plug-in debugging
#   262144  ACI summary information


DIRSRV_PORT=${DIRSRV_PORT:-389}
DIRSRV_ADMIN_PORT=${DIRSRV_ADMIN_PORT:-9830}

LDAP_LOG_LEVEL=${LDAP_LOG_LEVEL:-32}

DIRSRV_INSTALL_LDIF=/etc/dirsrv/domain.ldif

DIRSRV_ID=${DIRSRV_ID:-default}
DIRSRV_BASE=/etc/dirsrv/slapd-$DIRSRV_ID



if [ ! -d "$DIRSRV_BASE" ]; then
  echo "Configuring ${DIRSRV_BASE}..."

  # $HOSTNAME instead of DIRSRV_FQDN
  timeout 10 /usr/sbin/setup-ds.pl --silent --debug \
    "General.FullMachineName=$DIRSRV_FQDN" \
    "General.StrictHostCheck=false" \
    "General.SuiteSpotUserID=dirsrv" \
    "General.SuiteSpotGroup=dirsrv" \
    "General.ConfigDirectoryAdminID=$DIRSRV_ADMIN_USERNAME" \
    "General.ConfigDirectoryAdminPwd=$DIRSRV_ADMIN_PASSWORD" \
    "slapd.ServerIdentifier=$DIRSRV_ID" \
    "slapd.ServerPort=$DIRSRV_PORT" \
    "slapd.Suffix=$DIRSRV_SUFFIX" \
    "slapd.RootDN=$DIRSRV_ROOT_DN" \
    "slapd.RootDNPwd=$DIRSRV_ROOT_DN_PASSWORD" \
    "slapd.AddSampleEntries=0" \
    "slapd.AddOrgEntries=no" \
    "slapd.InstallLdifFile=$DIRSRV_INSTALL_LDIF" \
    "admin.Port=$DIRSRV_ADMIN_PORT" \
    "admin.ServerAdminID=$DIRSRV_ADMIN_USERNAME" \
    "admin.ServerAdminPwd=$DIRSRV_ADMIN_PASSWORD" || ERROR_CODE=$?

  echo "Configured. Error code $ERROR_CODE"


  # cp /etc/dirsrv/schema.ldif /$DIRSRV_BASE/schema/99user.ldif
  # echo "Installing custom schema"
  # cp /etc/dirsrv/wildlife.ldif /$DIRSRV_BASE/schema/98wildlife.ldif
fi

echo "Starting 389 Directory server..."

# touch /var/log/dirsrv/slapd-${DIRSRV_ID}/errors

/usr/sbin/ns-slapd -D ${DIRSRV_BASE} -d $LDAP_LOG_LEVEL
# \
#   && tail -F /var/log/dirsrv/slapd-${DIRSRV_ID}/errors
