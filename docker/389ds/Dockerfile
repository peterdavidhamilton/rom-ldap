FROM centos:7

LABEL maintainer="rom-ldap" \
      name="389ds"

ENV container "docker"

RUN yum -y install 389-ds-base \
    && rm -rf /usr/lib/systemd/system \
    && sed -i 's/updateSelinuxPolicy($inf);//g' /usr/lib64/dirsrv/perl/*

# $HOSTNAME
ENV DIRSRV_FQDN "example.org"
ENV DIRSRV_SUFFIX "dc=example,dc=org"

# auth
ENV DIRSRV_ROOT_DN "cn=Directory Manager"
ENV DIRSRV_ROOT_DN_PASSWORD "secret"

ENV DIRSRV_ADMIN_USERNAME "unused-admin"
ENV DIRSRV_ADMIN_PASSWORD "adminpassword"
ENV DIRSRV_ID "default"

COPY domain.ldif /etc/dirsrv/domain.ldif

EXPOSE 389 636 9830

ADD entrypoint.sh /entrypoint.sh

RUN chown dirsrv:dirsrv /entrypoint.sh \
    && chmod +x /entrypoint.sh

CMD /entrypoint.sh
