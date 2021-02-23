#!/bin/bash

WORKDIR=/apacheds/instances/$ADS_INSTANCE_NAME

rm -rf $WORKDIR/conf/ou=config*
rm -rf $WORKDIR/partitions/*

mkdir -p $WORKDIR/{cache,conf,log,partitions,run}

cp /config.ldif $WORKDIR/conf/

touch $WORKDIR/{log/apacheds.out,run/apacheds.pid}

/apacheds/bin/apacheds.sh $ADS_INSTANCE_NAME start

until curl -u 'uid=admin,ou=system:secret' ldap://localhost:10389/dc=rom,dc=ldap; do
  sleep 2
done

for i in wildlife nis; do
  ldapmodify -x \
    -D uid=admin,ou=system \
    -w secret \
    -H ldap://localhost:10389 \
    -a -c -v -f $i.ldif
done

tail -f $WORKDIR/log/apacheds.out

