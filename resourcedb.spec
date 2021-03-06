Summary:   NetSage Resource Database / Science Registry
Name:      resourcedb
Version:   0.12.0
Release:   %{_buildno}%{?dist}
License:   Apache
Group:     GRNOC
URL:       http://globalnoc.iu.edu
Source:    %{name}-%{version}.tar.gz

BuildArch: noarch
BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildRequires: perl
BuildRequires: httpd-devel
BuildRequires: mod_perl-devel

%if 0%{?rhel} < 7
Requires: GeoIP-GeoLite-data
Requires: GeoIP-GeoLite-data-extra
Requires: mysql
Requires: mysql-server
%else
Requires: GeoIP
Requires: GeoIP-data
Requires: mariadb
Requires: mariadb-server
%endif
Requires: httpd
Requires: perl-Data-Validate-IP
Requires: perl-DBD-MySQL
Requires: perl-Geo-IP
Requires: perl-MaxMind-DB-Writer
Requires: perl-MaxMind-DB-Reader
Requires: perl-Getopt-Long
Requires: perl-GRNOC-Config
Requires: perl-GRNOC-Log
Requires: perl-GRNOC-DatabaseQuery
Requires: perl-String-MkPasswd
Requires: perl-Net-DNS
Requires: perl-NetAddr-IP
Requires: perl-Net-IP
Requires: perl-JSON
Requires: perl-JSON-XS
Requires: perl-Email-Send
Requires: perl-MIME-Lite-TT
Requires: perl-MIME-Lite
Requires: perl-Text-CSV
Requires: perl-List-MoreUtils
Requires: perl-Encode
Requires: perl-GRNOC-Monitoring-Service-Status
Requires: grnoc-nagios-service-status-check
Requires: perl-Search-Elasticsearch

%description
NetSage Resource Database and User Interface (ie, Science Registry)

%prep
%setup -q -n resourcedb-%{version}

%build
%{__perl} Makefile.PL PREFIX="%{buildroot}%{_prefix}" INSTALLDIRS="vendor"


%install
# Perl modules
%{__install} -d -p %{buildroot}%{perl_vendorlib}/GRNOC/NetSage
%{__install} lib/GRNOC/NetSage/ResourceDB.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB.pm
%{__install} lib/GRNOC/NetSage/ResourceDB.pod %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB.pod

%{__install} -d -p %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService.pod %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService.pod
%{__install} lib/GRNOC/NetSage/ResourceDB/GWS.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/GWS.pod %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS.pod

%{__install} -d -p %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/Admin.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Admin.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/Admin.pod %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Admin.pod
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/Data.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Data.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/Data.pod %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Data.pod
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/External.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/External.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/External.pod %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/External.pod
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/Result.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Result.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/Result.pod %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Result.pod
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/User.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/User.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/User.pod %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/User.pod
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/Util.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Util.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/Util.pod %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Util.pod

%{__install} -d -p %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS
%{__install} lib/GRNOC/NetSage/ResourceDB/GWS/Admin.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/Admin.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/GWS/Admin.pod %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/Admin.pod
%{__install} lib/GRNOC/NetSage/ResourceDB/GWS/External.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/External.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/GWS/External.pod %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/External.pod
%{__install} lib/GRNOC/NetSage/ResourceDB/GWS/User.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/User.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/GWS/User.pod %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/User.pod

# HTTP and web files
%{__install} -d -p %{buildroot}%{_datadir}/resourcedb/www
cp -ar www/* %{buildroot}%{_datadir}/resourcedb/www

# dir for exported/downloaded db files
%{__install} -d -p %{buildroot}%{_datadir}/resourcedb/www/exported

# dir for status file
%{__install} -d -p %{buildroot}/var/lib/grnoc/scienceregistry-mmdb-file/

# Configuration and schema files
%{__install} -d -p %{buildroot}%{_sysconfdir}/grnoc/netsage/resourcedb
%{__install} -m 544 sql/resourcedb.sql %{buildroot}%{_sysconfdir}/grnoc/netsage/resourcedb

# Executable scripts
%{__install} -d -p %{buildroot}%{_bindir}
%{__install} -m 544 bin/resourcedb-init-db %{buildroot}%{_bindir}
%{__install} -m 544 bin/resourcedb-update-db %{buildroot}%{_bindir}
%{__install} -m 544 bin/resourcedb-export.pl %{buildroot}%{_bindir}
%{__install} -m 544 bin/resourcedb-make-mmdb.pl %{buildroot}%{_bindir}
%{__install} -m 544 bin/get-current-geoip %{buildroot}%{_bindir}

# example Cron files
%{__install} -m 644 cron/geoip-update.cron.example %{buildroot}/etc/ccron.d/geoip-update.cron.example
%{__install} -m 644 cron/resourcedb-export.cron.example %{buildroot}/etc/ccron.d/resourcedb-export.cron.example

# Misc scripts are not installed.        ok???

%check
make test_jenkins

%clean
rm -rf $RPM_BUILD_ROOT

%files
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB.pod
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService.pod
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Result.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Result.pod
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Admin.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Admin.pod
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Data.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Data.pod
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/External.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/External.pod
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/User.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/User.pod
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Util.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Util.pod
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS.pod
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/Admin.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/Admin.pod
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/External.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/External.pod
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/User.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/User.pod

%{_datadir}/resourcedb/www/

%{_sysconfdir}/grnoc/netsage/resourcedb/resourcedb.sql

%{_bindir}/resourcedb-update-db
%{_bindir}/resourcedb-init-db
%{_bindir}/resourcedb-make-mmdb.pl
%{_bindir}/resourcedb-export.pl
%{_bindir}/get-current-geoip
