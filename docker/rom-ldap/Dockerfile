FROM ruby:2.4.5-alpine3.8 as gem

RUN apk --no-cache upgrade && \
    apk --no-cache add build-base libxml2-dev openldap-clients git

ENV LDAPURI="ldap:://apacheds:10389" \
    LDAPBINDDN="uid=admin,ou=system" \
    LDAPBINDPW="secret" \
    LDAPDIR="/schema" \
    BUNDLE_PATH="/bundle" \
    BUNDLE_BIN="/bundle/bin" \
    GEM_HOME="/bundle" \
    PATH="${BUNDLE_BIN}:${PATH}"

VOLUME $LDAPDIR
VOLUME /src

WORKDIR /src

ENTRYPOINT ["/src/docker-entrypoint.sh"]

CMD ["rspec", "--fail-fast=10"]
