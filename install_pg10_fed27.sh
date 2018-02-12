# Fedora - disable old version

Add exclude to /etc/yum.repos.d/fedora.repo file [fedora] section:

```
[fedora]
...
exclude=postgresql*
Add exclude to /etc/yum.repos.d/fedora-updates.repo file [updates] section:
```

```
[updates]
...
exclude=postgresql*
```

## Fedora 27 ##

```
dnf install https://download.postgresql.org/pub/repos/yum/10/fedora/fedora-27-x86_64/pgdg-fedora10-10-3.noarch.rpm
```

# install

```
dnf install postgresql10 postgresql10-server
```

# initialize

```
## Fedora 27/26/25 and CentOS/RHEL/SL 7.4 ##
/usr/pgsql-10/bin/postgresql-10-setup initdb
```

Set PostgreSQL Server to Listen Addresses and Set Port
Open /var/lib/pgsql/10/data/postgresql.conf file, and add/uncomment/modify following:

Bash

listen_addresses = '*'
port = 5432
If you want just localhost setup, then use following:

Bash

listen_addresses = 'localhost'
port = 5432
Or if you want use specific ip, then use following:

Bash

listen_addresses = '192.1.2.33'
port = 5432
2.3 Set PostgreSQL Permissions
Modify PostgreSQL /var/lib/pgsql/10/data/pg_hba.conf (host-based authentication) file:

Bash

# Local networks
host	all	all	        xx.xx.xx.xx/xx	md5
# Example
host	all	all     	10.20.4.0/24	md5
# Example 2
host	test	testuser	127.0.0.1/32	md5
You can find more examples and full guide from PostgreSQL pg_hba.conf manual.

2.4 Start PostgreSQL Server and Autostart PostgreSQL on Boot
Fedora 27/26/25 and CentOS/Red Hat (RHEL)/Scientific Linux (SL) 7.4
Bash

## Start PostgreSQL 10 ##
systemctl start postgresql-10.service

## Start PostgreSQL 10 on every boot ##
systemctl enable postgresql-10.service
CentOS/Red Hat (RHEL)/Scientific Linux (SL) 6.9
Bash

## Start PostgreSQL 10 ##
service postgresql-10 start
## OR ##
/etc/init.d/postgresql-10 start

## Start PostgreSQL 10 on every boot ##
chkconfig --levels 235 postgresql-10 on
2.5 Create Test Database and Create New User
Change to postgres user
Bash

su postgres
Create test database (as postgres user)
Bash

createdb test
Login test database (as postgres user)
Bash

psql test
Create New “testuser” Role with Superuser and Password
SQL

CREATE ROLE testuser WITH SUPERUSER LOGIN PASSWORD 'test';
Test Connection from localhost (as Normal Linux User)
Bash

psql -h localhost -U testuser test

firewall-cmd --get-active-zones

Add New Rule to Firewalld
You might have active zone like public, FedoraWorkstation, FedoraServer.

Bash

firewall-cmd --permanent --zone=public --add-service=postgresql

## OR ##

firewall-cmd --permanent --zone=public --add-port=5432/tcp

Restart firewalld.service
Bash

systemctl restart firewalld.service
4. Test remote connection
Bash

psql -h dbserver_name_or_ip_address -U testuser -W test
