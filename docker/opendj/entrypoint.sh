#!/bin/sh
# https://github.com/OpenIdentityPlatform/OpenDJ/wiki/Installation-Guide#to-install-opendj-directory-server-from-the-command-line

/opendj/setup \
--cli \
--acceptLicense \
--verbose \
--no-prompt \
--doNotStart \
--enableStartTLS \
--generateSelfSignedCertificate \
--hostname rom.ldap \
--baseDN dc=rom,dc=ldap \
--rootUserPassword topsecret \
--ldifFile /opendj/domain.ldif

/opendj/bin/start-ds --systemInfo

/opendj/bin/status

/opendj/bin/start-ds --nodetach

tail -F /opendj/logs/error