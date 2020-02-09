#!/bin/sh

set -e

# latest version of bundler
gem install bundler --no-document

# install gems
bundle check || bundle install --binstubs="$BUNDLE_BIN"

# update gem executables
bundle binstubs bundler --force

# prepare directory schema
bundle exec rake ldap:modify

exec bundle exec "$@"
