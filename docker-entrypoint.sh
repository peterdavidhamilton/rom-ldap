#!/bin/sh

set -e

gem install bundler --no-document

bundle check || bundle install

exec bundle exec "$@"
