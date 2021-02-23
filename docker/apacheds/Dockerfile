FROM java:alpine

LABEL maintainer="rom-ldap" \
      name="apacheds" \
      description="ApacheDS for ROM-LDAP"

ARG version=2.0.0-M24
ARG repo=archive.apache.org

ENV APACHEDS_URL "https://$repo/dist/directory/apacheds/dist/$version/apacheds-$version.tar.gz"
ENV APACHEDS_VERSION $version
ENV CURL_VERSION 7.65.3

RUN apk --no-cache upgrade; \
    apk --no-cache --update add openssl; \
    apk --no-cache add bash build-base openldap-dev openldap-clients; \
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
    curl $APACHEDS_URL -o apacheds-$version.tar.gz; \
    tar -xvf apacheds-$version.tar.gz; \
    rm apacheds-$version.tar.gz; \
    mv apacheds-$version /apacheds

EXPOSE 10389 10636 60088 60464 8080 8443

ARG instance=rom

ENV ADS_INSTANCE_NAME $instance

COPY $ADS_INSTANCE_NAME/*.ldif /

COPY $ADS_INSTANCE_NAME/log4j.properties /apacheds/instances/$ADS_INSTANCE_NAME/conf/

COPY entrypoint.sh /

ENTRYPOINT /entrypoint.sh
