# resourcedb
NetSage Resource Database (Science Registry or ResourceDB)

Registry for pairing IP addresses or CIDR ranges with organizations, disciplines, roles, projects, etc.

## Installation

To quickly build the package use the following command. The release
number is set to 1 by default, but may be modified in `Makefile.PL` or
by setting the `BUILD_NUMBER` environment variable.

```
perl Makefile.PL
make manifest
make rpm
> resourcedb-0.0.1-1.el7.centos.noarch.rpm
sudo yum install resourcedb-0.0.1-1.el7.centos.noarch.rpm
```

If this is your first time running ResourceDB, use the database init
script to create database users and the config file. The generated
configuration file will be stored at
`/etc/grnoc/resourcedb/config.xml`.

```
sudo resourcedb-init-db
```

Then, and after every upgrade of ResourceDB, run the database upgrade script 
to set up the database and/or make any changes needed.

```
sudo resourcedb-update-db
```
