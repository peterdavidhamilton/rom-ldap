#!/usr/bin/dumb-init /bin/bash

APACHEDS_INSTANCE_DIRECTORY="${APACHEDS_DATA}/${APACHEDS_INSTANCE}"
PIDFILE="${APACHEDS_INSTANCE_DIRECTORY}/run/apacheds-${APACHEDS_INSTANCE}.pid"


if [ ! -d ${APACHEDS_INSTANCE_DIRECTORY} ]; then
  echo "Configuring new instance ${APACHEDS_INSTANCE}"
  mkdir -p ${APACHEDS_INSTANCE_DIRECTORY}
  cp -rv ${APACHEDS_BOOTSTRAP}/* ${APACHEDS_INSTANCE_DIRECTORY}
  chown -v -R apacheds:apacheds ${APACHEDS_INSTANCE_DIRECTORY}
fi

cleanup(){
  if [ -e "${PIDFILE}" ]; then
    echo "Cleaning up ${PIDFILE}"
    rm "${PIDFILE}"
  fi
}

trap cleanup EXIT
cleanup

shutdown(){
  echo "Shutting down..."
  /opt/apacheds-${APACHEDS_VERSION}/bin/apacheds stop ${APACHEDS_INSTANCE}
}

trap shutdown INT TERM

echo "Starting ApacheDS server..."

/opt/apacheds-${APACHEDS_VERSION}/bin/apacheds start ${APACHEDS_INSTANCE}
sleep 20

echo "Loading custom schemas..."

for schema in /schema/*.ldif; do
  /usr/bin/ldapadd -x -c -v -f $schema
done

tail -F ${APACHEDS_INSTANCE_DIRECTORY}/log/apacheds.log
