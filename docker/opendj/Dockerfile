FROM java:alpine

LABEL maintainer="rom-ldap" \
      name="opendj" \
      description="OPENDJ service for ROM-LDAP"

ARG version=4.4.9

ENV OPENDJ_URL "https://github.com/OpenIdentityPlatform/OpenDJ/releases/download/$version/opendj-$version.zip"

RUN apk --no-cache upgrade; \
    apk --no-cache add curl; \
    curl -L $OPENDJ_URL -o opendj-$version.zip; \
    unzip opendj-$version.zip; \
    rm opendj-$version.zip

EXPOSE 389 636 4444

ARG instance=rom

COPY $instance/domain.ldif /opendj

COPY $instance/wildlife.ldif /opendj/template/config/schema/99-user.ldif

COPY entrypoint.sh /

ENTRYPOINT /entrypoint.sh
