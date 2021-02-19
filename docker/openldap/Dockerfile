# https://pkgs.alpinelinux.org/package/edge/main/x86_64/openldap
# https://www.openldap.org/software/release/changes.html
FROM alpine

LABEL maintainer="rom-ldap" \
      name="openldap" \
      description="OPENLDAP service for ROM-LDAP"

RUN apk --no-cache upgrade; \
    apk --no-cache add openldap-back-mdb openldap-overlay-sssvlv openldap openldap-clients; \
    mkdir -p /var/lib/openldap/openldap-data; \
    chmod 700 /var/lib/openldap/openldap-data; \
    mkdir -p /etc/openldap/slapd.d; \
    chmod 700 /etc/openldap/slapd.d

EXPOSE 389 636

VOLUME /var/run

ENV SLAPD_OPTIONS="-s 256"

ARG instance=rom

COPY $instance/slapd.conf /etc/openldap/

COPY $instance/*.schema /etc/openldap/schema/

COPY $instance/*.ldif /etc/openldap/

COPY entrypoint.sh /

ENTRYPOINT /entrypoint.sh
