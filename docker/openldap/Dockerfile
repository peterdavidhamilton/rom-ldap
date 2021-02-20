# https://pkgs.alpinelinux.org/package/edge/main/x86_64/openldap
# https://www.openldap.org/software/release/changes.html
FROM alpine:latest

LABEL maintainer="rom-ldap" \
      name="openldap" \
      description="OPENLDAP for ROM-LDAP"

ENV CURL_VERSION 7.65.3

RUN apk --no-cache upgrade; \
    apk --no-cache add build-base openldap-dev \
    openldap-back-mdb openldap-overlay-sssvlv openldap openldap-clients; \
    apk --no-cache --virtual add curldeps; \
    wget https://curl.haxx.se/download/curl-$CURL_VERSION.tar.bz2; \
    tar xjvf curl-$CURL_VERSION.tar.bz2; \
    rm curl-$CURL_VERSION.tar.bz2; \
    cd curl-$CURL_VERSION; \
    ./configure --prefix=/usr --enable-ldap --enable-ldaps; \
    make; \
    make install; \
    cd /; \
    rm -r curl-$CURL_VERSION; \
    rm -r /var/cache/apk; \
    rm -r /usr/share/man; \
    apk del curldeps openldap-dev build-base; \
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
