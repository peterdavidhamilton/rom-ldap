#!/bin/bash

/usr/sbin/setup-ds.pl --silent --debug --file /config.inf

/usr/sbin/ns-slapd -D /etc/dirsrv/slapd-$DIRSRV_ID -d 6
