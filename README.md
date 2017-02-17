# resourcedb
NetSage Resource Database (Science Registry)

Registry for pairing CIDR ranges with discipline, role, project, etc.

## Installation

To quickly build the package use the following command. The release
number is set to 1 by default, but may be modified in `Makefile.PL` or
by setting the `BUILD_NUMBER` environment variable.

```
perl Makefile.PL
make manifest
make rpm
> resourcedb-0.0.1-1.el7.centos.noarch.rpm
```
