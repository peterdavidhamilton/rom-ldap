# README



## Commands

Run commands inside the running docker containers.
To detach the tty without exiting the shell, use the escape sequence `Ctrl-p` + `Ctrl-q`


1. Run specs  
    `$ docker exec -i -t rom-ldap bundle exec rspec`

2. Run console with debugging enabled  
    `$ docker exec -i -t -e DEBUG=y rom-ldap ./bin/console`

3. Run demo with debugging enabled  
    `$ docker exec -i -t -e DEBUG=y rom-ldap ./bin/demo`

4. Run benchmarks  
    `$ docker exec -i -t rom-ldap ./bin/benchmark`

5. Command line  
    `$ docker exec -i -t opendj /bin/bash`




## Registry

Replacing the [CI/CD](https://gitlab.com/peterdavidhamilton/rom-ldap/settings/ci_cd) docker images.

```bash
$ cd ./docker/apacheds
$ docker build -t registry.gitlab.com/peterdavidhamilton/rom-ldap/apacheds:latest .
$ docker push registry.gitlab.com/peterdavidhamilton/rom-ldap/apacheds:latest
```

https://gitlab.com/help/ssh/README#generating-a-new-ssh-key-pair
https://docs.gitlab.com/ee/ci/ssh_keys/README.html

Create passwordless ssh key for access to private repos (ldap-ber).

`$ ssh-keygen -o -t rsa -b 4096 -C "rom-ldap CI/CD"`
`$ pbcopy < ~/.ssh/rom-ldap`


