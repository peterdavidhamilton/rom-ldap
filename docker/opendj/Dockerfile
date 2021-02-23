FROM java:alpine

LABEL maintainer="rom-ldap" \
      name="opendj" \
      description="OPENDJ for ROM-LDAP"

ARG version=4.4.9

ENV OPENDJ_URL "https://github.com/OpenIdentityPlatform/OpenDJ/releases/download/$version/opendj-$version.zip"
ENV CURL_VERSION 7.65.3

RUN apk --no-cache upgrade; \
    apk --no-cache --update add openssl; \
    apk --no-cache add bash build-base openldap-dev; \
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
    curl -L $OPENDJ_URL -o opendj-$version.zip; \
    unzip opendj-$version.zip; \
    rm opendj-$version.zip

EXPOSE 389 636 4444

ARG instance=rom

COPY $instance/domain.ldif /opendj

COPY $instance/wildlife.ldif /opendj/template/config/schema/99-user.ldif

COPY entrypoint.sh /

ENTRYPOINT /entrypoint.sh
