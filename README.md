# resourcedb
NetSage Resource Database (Science Registry)

Registry for pairing CIDR ranges with discipline, role, project, etc.

## Installation

To quickly build the package use the following command. The release
number is set to 1 by default, may be modified in `Makefile.PL`.

```
perl Makefile.PL
make manifest
make rpm
> resourcedb-0.0.1-1.el7.centos.noarch.rpm
```

You can manually set the release number by settting the `BUILD_NUMBER`
environment variable and using `rpm_jenkins`.

```
export BUILD_NUMBER=123
perl Makefile.PL
make manifest
make rpm_jenkins
> resourcedb-0.0.1-123.el7.centos.noarch.rpm
```
