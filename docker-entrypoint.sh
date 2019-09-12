#!/bin/sh

set -e

bundle install

bundle exec rake ldap:modify

exec bundle exec "$@"
