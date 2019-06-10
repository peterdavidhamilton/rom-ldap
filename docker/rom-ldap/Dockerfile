# docker build -t rom-ldap . -f ./docker/rom-ldap/Dockerfile
#
FROM ruby:2.4.5-alpine3.8 as gem

# install ldapsearch to run a health check before specs
RUN apk --no-cache upgrade && \
    apk --no-cache add build-base libxml2-dev openldap-clients

RUN gem install bundler && bundle config git.allow_insecure true

COPY . /src

WORKDIR /src

#
# ./bundle/config cache => true
#
RUN bundle install --deployment

# docker exec -i -t rom-ldap spec
# ENTRYPOINT ["/usr/local/bundle/bin/bundle exec"]
# CMD ["rake -T"]