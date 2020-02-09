# docker build -t registry.gitlab.com/peterdavidhamilton/rom-ldap/openldap:2.4.48 .
#
# https://packages.debian.org/buster-backports/slapd
FROM debian:buster-slim

LABEL maintainer="rom-ldap" \
      name="openldap" \
      version="2.4.48"

RUN echo "deb http://ftp.debian.org/debian buster-backports main" >> /etc/apt/sources.list \
    && echo "path-include /usr/share/doc/krb5*" >> /etc/dpkg/dpkg.cfg.d/docker \
    && apt-get -y update \
    && LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get -t buster-backports install -y --no-install-recommends \
      ldap-utils \
      libsasl2-modules \
      libsasl2-modules-db \
      libsasl2-modules-gssapi-mit \
      libsasl2-modules-ldap \
      libsasl2-modules-otp \
      libsasl2-modules-sql \
      openssl \
      slapd \
      krb5-kdc-ldap \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ssl-cert

ENV LDAP_ORGANISATION "Example Inc."
ENV LDAP_DOMAIN "example.com"
ENV LDAP_BASE_DN "dc=example,dc=com"
ENV LDAP_ADMIN_PASSWORD "secret"
ENV LDAP_LOG_LEVEL "256"

EXPOSE 389 636

VOLUME /etc/ldap/slapd.d /var/lib/ldap

ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /etc/ldap

ENTRYPOINT ["/entrypoint.sh"]
