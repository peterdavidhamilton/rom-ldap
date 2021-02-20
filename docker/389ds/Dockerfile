FROM centos:7

LABEL maintainer="rom-ldap" \
      name="389ds" \
      description="389DS for ROM-LDAP"

ENV container "docker"

RUN yum -y install 389-ds-base; \
    yum clean all

EXPOSE 389 636 9830

ARG instance=rom

ENV DIRSRV_ID $instance

COPY $instance/wildlife.ldif /etc/dirsrv/schema/99user.ldif

COPY $instance/domain.ldif /

COPY $instance/config.inf /

COPY entrypoint.sh /

ENTRYPOINT /entrypoint.sh
