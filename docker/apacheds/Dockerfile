FROM ubuntu:18.04

LABEL maintainer="rom-ldap" \
      name="apacheds"

# Update and install prerequisites
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      wget \
      dumb-init \
      default-jre-headless \
      ldap-utils \
      procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download and install ApacheDS
ARG version=2.0.0-M24
ARG architecture=amd64

ENV APACHEDS_VERSION $version
ENV APACHEDS_ARCH $architecture
ENV APACHEDS_ARCHIVE "apacheds-$APACHEDS_VERSION-$APACHEDS_ARCH.deb"
ENV APACHEDS_URL "http://www.eu.apache.org/dist/directory/apacheds/dist/${APACHEDS_VERSION}/${APACHEDS_ARCHIVE}"

RUN wget --quiet ${APACHEDS_URL} \
    && dpkg -i ${APACHEDS_ARCHIVE} \
    && rm ${APACHEDS_ARCHIVE}


# Configure server
ENV APACHEDS_INSTANCE "default"
ENV APACHEDS_BOOTSTRAP "/bootstrap"
ENV APACHEDS_DATA "/var/lib/apacheds"

RUN ln -s ${APACHEDS_DATA}-${APACHEDS_VERSION} ${APACHEDS_DATA}

ADD instance/* ${APACHEDS_BOOTSTRAP}/conf/

RUN mkdir ${APACHEDS_BOOTSTRAP}/cache \
    && mkdir ${APACHEDS_BOOTSTRAP}/run \
    && mkdir ${APACHEDS_BOOTSTRAP}/log \
    && mkdir ${APACHEDS_BOOTSTRAP}/partitions \
    && chown -R apacheds:apacheds ${APACHEDS_BOOTSTRAP}

# Correct for hard-coded INSTANCES_DIRECTORY variable
RUN sed -i "s#/var/lib/apacheds-${APACHEDS_VERSION}#/var/lib/apacheds#" /opt/apacheds-${APACHEDS_VERSION}/bin/apacheds


# Finalize
VOLUME ${APACHEDS_DATA}

EXPOSE 10389 10636 60088 60464 8080 8443

ADD entrypoint.sh /entrypoint.sh

RUN chown apacheds:apacheds /entrypoint.sh \
    && chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
