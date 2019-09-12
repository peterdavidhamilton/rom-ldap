FROM ruby:2.4.5-alpine3.8 as gem

RUN apk --no-cache upgrade && \
    apk --no-cache add build-base libxml2-dev openldap-clients git && \
    gem install bundler --no-document

ENV LDAPHOST="apacheds" \
    LDAPPORT="10389" \
    LDAPBASE="dc=rom,dc=ldap" \
    LDAPBINDDN="uid=admin,ou=system" \
    LDAPBINDPW="secret" \
    LDAPDIR="/schema"

VOLUME $LDAPDIR
VOLUME /src

WORKDIR /src

ENTRYPOINT ["/src/docker-entrypoint.sh"]

CMD ["rspec", "--fail-fast=10"]
