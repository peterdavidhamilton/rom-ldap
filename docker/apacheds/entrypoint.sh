#!/usr/bin/dumb-init /bin/bash

APACHEDS_INSTANCE_DIRECTORY="${APACHEDS_DATA}/${APACHEDS_INSTANCE}"
PIDFILE="${APACHEDS_INSTANCE_DIRECTORY}/run/apacheds-${APACHEDS_INSTANCE}.pid"

function cleanup {
  if [ -e "${PIDFILE}" ]
  then
    echo "Cleaning up ${PIDFILE}"
    rm "${PIDFILE}"
  fi
}

trap cleanup EXIT

function shutdown {
  /opt/apacheds-${APACHEDS_VERSION}/bin/apacheds stop ${APACHEDS_INSTANCE}
}

trap shutdown INT TERM


if [ ! -d ${APACHEDS_INSTANCE_DIRECTORY} ]
then
  echo "
===================================================
Configuring new instance ${APACHEDS_INSTANCE}...
===================================================
"
  mkdir -p ${APACHEDS_INSTANCE_DIRECTORY}
  cp -rv ${APACHEDS_BOOTSTRAP}/* ${APACHEDS_INSTANCE_DIRECTORY}
  chown -v -R apacheds:apacheds ${APACHEDS_INSTANCE_DIRECTORY}
else
  echo "
===================================================
Instance ${APACHEDS_INSTANCE} is already configured
===================================================
"
fi


/opt/apacheds-${APACHEDS_VERSION}/bin/apacheds start ${APACHEDS_INSTANCE}

tail -F ${APACHEDS_INSTANCE_DIRECTORY}/log/apacheds.log
