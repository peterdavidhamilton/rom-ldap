#!/bin/sh

set -e

gem install bundler --no-document

bundle binstubs bundler --force

bundle check || bundle install --binstubs="$BUNDLE_BIN"

bundle exec rake ldap:modify

exec bundle exec "$@"
