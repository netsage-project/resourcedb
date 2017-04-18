Summary:   NetSage Resource Database
Name:      resourcedb
Version:   0.0.3
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
%else
Requires: GeoIP
Requires: GeoIP-data
%endif
Requires: mariadb
Requires: mariadb-server
Requires: perl-Data-Validate-IP
Requires: perl-DBD-MySQL
Requires: perl-Geo-IP
Requires: perl-GRNOC-Config
Requires: perl-GRNOC-Log
Requires: perl-MIME-Lite-TT
Requires: perl-String-MkPasswd

%description
NetSage Resource Database (Science Registry)

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

# lib/GRNOC/NetSage/ResourceDB/DataService/Data.pm

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

# Configuration and schema files
%{__install} -d -p %{buildroot}%{_sysconfdir}/grnoc/netsage/resourcedb

%{__install} -m 544 sql/resourcedb.sql %{buildroot}%{_sysconfdir}/grnoc/netsage/resourcedb

# Executables
%{__install} -d -p %{buildroot}%{_bindir}

%{__install} -m 544 bin/resourcedb-init-db %{buildroot}%{_bindir}
%{__install} -m 544 bin/resourcedb-update-db %{buildroot}%{_bindir}

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

%{_bindir}/resourcedb-init-db
%{_bindir}/resourcedb-update-db
