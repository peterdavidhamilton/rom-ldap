FROM java:alpine

LABEL maintainer="rom-ldap" \
      name="apacheds" \
      description="ApacheDS service for ROM-LDAP"

ARG version=2.0.0-M24
ARG repo=archive.apache.org

ENV APACHEDS_URL "https://$repo/dist/directory/apacheds/dist/$version/apacheds-$version.tar.gz"
ENV APACHEDS_VERSION $version

RUN apk --no-cache upgrade; \
    apk --no-cache add curl bash openldap-clients; \
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
