# README

- `$ cd ./docker/apacheds`
- `$ docker build -t registry.gitlab.com/peterdavidhamilton/rom-ldap/apacheds:latest .`
- `$ docker push registry.gitlab.com/peterdavidhamilton/rom-ldap/apacheds:latest`



<https://directory.fedoraproject.org/>

Suite currently built against ApacheDS

<http://www.openldap.org/faq/data/cache/649.html>

    The OpenLDAP server does not implement the following Standard Track (and elective) extensions:

    - Server Side Sorting of Search Results [RFC 2891] (use client side sorting instead)
    - Collective Attributes [RFC 3671] (use collective overlay instead)
    - LCUP [RFC 3928] (use LDAPsync instead)






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

brew install ldapvi

DIT directory information tree
<!--
  10.0.2.15 on port 8443 (pcsync-https)
  name-zone.aet.leedsbeckett.ac.uk  160.9.103.163
  vito-gw.inn.leedsmet.ac.uk        160.9.120.8
 -->


Note that "CN" and "SN" are subtypes of "name"

Save binaries to tmp files
`$ ldapsearch -LLL -x -H ldap://127.0.0.1:10389 -t -b "dc=example,dc=com" "uid=root"`

Show encoded binaries
`$ ldapsearch -LLL -x -H ldap://127.0.0.1:10389 -T -b "dc=example,dc=com" "uid=root"`

Search entry in AD
`$ ldapsearch -xLLL -H ldap://addc4.leedsbeckett.ac.uk -b "ou=staff,ou=usr,dc=leedsbeckett,dc=ac,dc=uk" -D "hamilt09@leedsbeckett.ac.uk" -W "cn=Hamilt09"`

Run modification from LDIF
`$ ldapmodify -x -D "uid=admin,ou=system" -w secret -H ldap://127.0.0.1:10389 -f changeset.ldif`

Output LDIF
`$ ldapvi -h ldap://addc4 -b ou=staff,ou=usr,dc=leedsbeckett,dc=ac,dc=uk -D hamilt09@leedsbeckett.ac.uk -w "escapedpassword" --ldif --out "(cn=Hamilt09)"`

Convert binary to LDIF
`$ ldif -b jpegPhoto <  mark.jpg > out.ldif`

Changeset#to_s outputs an LDIF command

    dn: uid=jsmith1,ou=People,dc=example,dc=com
    changetype: add
    objectClass: inetOrgPerson
    description: John Smith from Accounting.  John is the project
      manager of the building project, so contact him with any qu
     estions.
    cn: John Smith
    sn: Smith
    uid: jsmith1


    dn: ou=othergroup,dc=example,dc=com
    changetype: delete


    dn: entry_to_add_attribute
    changetype: modify
    add: attribute_type
    attribute_type: value_to_set