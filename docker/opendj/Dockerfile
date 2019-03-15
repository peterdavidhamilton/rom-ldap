FROM java:8

LABEL maintainer="rom-ldap" \
      name="opendj"

ARG version=4.3.1

ENV OPENDJ_URL https://github.com/OpenIdentityPlatform/OpenDJ/releases/download/$version/opendj-$version.zip


ENV BASE_DN "dc=example,dc=com"
ENV ROOT_USER_DN "cn=Directory Manager"
ENV ROOT_PASSWORD "secret"


WORKDIR /opt

RUN wget --quiet $OPENDJ_URL \
    && unzip opendj-$version.zip \
    && rm opendj-$version.zip

RUN useradd -m -r -u 1001 -g root opendj

RUN chgrp -R 0 /opt/opendj \
    && chmod -R g=u /opt/opendj

EXPOSE 389 636 4444

# COPY wildlife.ldif /opt/opendj/config/schema/98-wildlife.ldif
# COPY wildlife.ldif /opt/opendj/config/schema/99-user.ldif

# COPY wildlife.ldif /ldif/wildlife.ldif
COPY domain.ldif /ldif/domain.ldif

VOLUME /opt/opendj

ADD entrypoint.sh /entrypoint.sh

RUN chown opendj /entrypoint.sh \
    && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]