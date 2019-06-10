# README

To detach the tty without exiting the shell, use the escape sequence Ctrl-p + Ctrl-q

## CI/CD Setup

`$ docker-machine stop rancher`

`$ VBoxManage modifyvm rancher --cpus 2`

`$ VBoxManage modifyvm rancher --memory 6144`

`$ docker-machine start rancher`

**Test Suite**

inside container
`$ docker exec -i -t rom-ldap bundle exec rake spec`

locally
- `$ LDAPURI=ldap://rancher:1389 bundle exec rake spec`
- `$ LDAPPORT=10389 rspec`


**Console**

Enter console with debugging enabled inside container
`$ docker exec -i -t -e DEBUG=y rom-ldap ./bin/console`

Run console locally
`$ LDAPURI=ldap://rancher:1389 ./bin/console`



**Demo**

inside container
`$ docker exec -i -t -e DEBUG=y rom-ldap ./bin/demo`

locally
`$ LDAPURI=ldap://rancher:1389 ./bin/demo`



**Benchmark**

inside container
`$ docker exec -i -t rom-ldap ./bin/benchmark`

locally
`$ LDAPHOST=rancher LDAPPORT=1389 LDAPBASE=dc=rom,dc=ldap LDAPBINDDN=uid=admin,ou=system LDAPBINDPW=secret ./bin/benchmark`




* OpenLDAP - cn=admin,cn=config       secret
* ApacheDS - uid=admin,ou=system      secret
* 389      - cn=Directory Manager     topsecret
* OpenDJ   - cn=Directory Manager     secret




https://gitlab.com/peterdavidhamilton/rom-ldap/settings/ci_cd
https://gitlab.com/help/ssh/README#generating-a-new-ssh-key-pair
https://docs.gitlab.com/ee/ci/ssh_keys/README.html

Create passwordless ssh key for access to private repos (ldap-ber).

`$ ssh-keygen -o -t rsa -b 4096 -C "rom-ldap CI/CD"`
`$ pbcopy < ~/.ssh/rom-ldap`


- `$ cd ./docker/apacheds`
- `$ docker build -t registry.gitlab.com/peterdavidhamilton/rom-ldap/apacheds:latest .`
- `$ docker push registry.gitlab.com/peterdavidhamilton/rom-ldap/apacheds:latest`


`$ docker exec -i -t -e DEBUG=y rom-ldap bundle exec rake spec`


<https://directory.fedoraproject.org/>

Suite currently built against ApacheDS

<http://www.openldap.org/faq/data/cache/649.html>

    The OpenLDAP server does not implement the following Standard Track (and elective) extensions:

    - Server Side Sorting of Search Results [RFC 2891] (use client side sorting instead)
    - Collective Attributes [RFC 3671] (use collective overlay instead)
    - LCUP [RFC 3928] (use LDAPsync instead)




connect to container command line

`$ docker exec -i -t opendj /bin/bash`


start open-ldap

`$ docker run --name my-openldap-container -p 3897:389 --detach osixia/openldap:1.2.0`

query docker-machine exposed port

`$ ldapsearch -x -H ldap://$(docker-machine ip default):3897 -b dc=example,dc=org -D "cn=admin,dc=example,dc=org" -w admin`


    docker run --name my-openldap-container --detach osixia/openldap:1.2.0

    docker run --rm -it app bundle exec puma -e production -b 'tcp://0.0.0.0:3000'

    docker run -d -p 5000:5000 --restart=always --name registry registry:2

    docker run -i -t -e INPUT=IMG_0109.JPG.jpeg -e ITER=20 -e SCALE=0.10 -e MODEL='inception_3b/5x5_reduce' -v ~/Desktop:/data herval/deepdream

https://docs.oracle.com/cd/E19424-01/820-4811/fnyth/
https://www.centos.org/docs/5/html/CDS/ag/8.0/LDIF_File_Format-Representing_Binary_Data.html
https://www.digitalocean.com/community/tutorials/how-to-use-ldif-files-to-make-changes-to-an-openldap-system#an-aside-adding-binary-data-to-an-entry


Increase resource limits for the docker-machine to enable tests to run quickly



docker run -m=4g {imageID}



Save binaries to tmp files
`$ ldapsearch -LLL -x -H ldap://127.0.0.1:10389 -t -b "dc=example,dc=com" "uid=root"`

Show encoded binaries
`$ ldapsearch -LLL -x -H ldap://127.0.0.1:10389 -T -b "dc=example,dc=com" "uid=root"`

Search entry in AD
`$ ldapsearch -xLLL -H ldap://ldap.example.com -b "ou=staff,ou=usr,dc=example,dc=com" -D "user@example.com" -W "cn=user"`

Run modification from LDIF
`$ ldapmodify -x -D "uid=admin,ou=system" -w secret -H ldap://127.0.0.1:10389 -f changeset.ldif`

Output LDIF
`$ ldapvi -h ldap://ldap -b ou=staff,ou=usr,dc=example,dc=com -D user@example.com -w "escapedpassword" --ldif --out "(cn=user)"`

Convert binary to LDIF
`$ ldif -b jpegPhoto <  mark.jpg > out.ldif`

