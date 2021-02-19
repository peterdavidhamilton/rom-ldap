ARG version=2.4

FROM ruby:$version-alpine as gem

LABEL description="ROM-LDAP Test Suite Container"

RUN apk --no-cache upgrade; \
    apk --no-cache add build-base libxml2-dev

ENV LDAPDIR="/schema" \
    BUNDLE_PATH="/bundle" \
    BUNDLE_BIN="/bundle/bin" \
    GEM_HOME="/bundle" \
    PATH="${BUNDLE_BIN}:${PATH}"

VOLUME $LDAPDIR /src

WORKDIR /src

ENTRYPOINT ["/src/docker-entrypoint.sh"]

CMD ["rspec", "--fail-fast=10"]
