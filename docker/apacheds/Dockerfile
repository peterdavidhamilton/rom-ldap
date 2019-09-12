FROM ubuntu:18.04

LABEL maintainer="rom-ldap" \
      name="apacheds"

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      wget \
      dumb-init \
      default-jre-headless \
      ldap-utils \
      procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ARG version=2.0.0.AM25
ARG architecture=amd64
# ARG repo=www.eu.apache.org
ARG repo=archive.apache.org

ENV APACHEDS_VERSION $version
ENV APACHEDS_REPO $repo
ENV APACHEDS_ARCH $architecture

ENV LDAPURI "ldap://127.0.0.1:10389"

ENV APACHEDS_ARCHIVE "apacheds-${APACHEDS_VERSION}-${APACHEDS_ARCH}.deb"
ENV APACHEDS_URL "https://${APACHEDS_REPO}/dist/directory/apacheds/dist"

RUN wget --quiet --no-check-certificate ${APACHEDS_URL}/${APACHEDS_VERSION}/${APACHEDS_ARCHIVE} \
    && dpkg -i ${APACHEDS_ARCHIVE} \
    && rm ${APACHEDS_ARCHIVE}

ENV APACHEDS_INSTANCE "default"
ENV APACHEDS_BOOTSTRAP "/bootstrap"
ENV APACHEDS_DATA "/var/lib/apacheds"
ENV APACHEDS_BIN "/opt/apacheds-${APACHEDS_VERSION}/bin"
ENV PATH "${PATH}:${APACHEDS_BIN}"

RUN ln -s ${APACHEDS_DATA}-${APACHEDS_VERSION} ${APACHEDS_DATA}

ADD instance/* ${APACHEDS_BOOTSTRAP}/conf/

RUN mkdir ${APACHEDS_BOOTSTRAP}/cache \
    && mkdir ${APACHEDS_BOOTSTRAP}/run \
    && mkdir ${APACHEDS_BOOTSTRAP}/log \
    && mkdir ${APACHEDS_BOOTSTRAP}/partitions


# Correct for hard-coded INSTANCES_DIRECTORY variable
RUN sed -i "s#/var/lib/apacheds-${APACHEDS_VERSION}#/var/lib/apacheds#" ${APACHEDS_BIN}/apacheds


VOLUME ${APACHEDS_DATA}

EXPOSE 10389 10636 60088 60464 8080 8443

ADD entrypoint.sh /entrypoint.sh

RUN chown apacheds:apacheds /entrypoint.sh \
    && chmod +x /entrypoint.sh

WORKDIR ${APACHEDS_DATA}

CMD /entrypoint.sh
