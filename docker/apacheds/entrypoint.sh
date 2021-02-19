#!/bin/bash

WORKDIR=/apacheds/instances/$ADS_INSTANCE_NAME

rm -rf $WORKDIR/conf/ou=config*
rm -rf $WORKDIR/partitions/*

mkdir -p $WORKDIR/{cache,conf,log,partitions,run}

cp /config.ldif $WORKDIR/conf/

touch $WORKDIR/{log/apacheds.out,run/apacheds.pid}

/apacheds/bin/apacheds.sh $ADS_INSTANCE_NAME start


sleep 10

ldapmodify -x -D uid=admin,ou=system -w secret -H ldap://localhost:10389 -a -c -v -f wildlife.ldif
ldapmodify -x -D uid=admin,ou=system -w secret -H ldap://localhost:10389 -a -c -v -f nis.ldif


tail -f $WORKDIR/log/apacheds.out

