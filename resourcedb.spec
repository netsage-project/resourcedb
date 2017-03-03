Summary:   NetSage Resource Database
Name:      resourcedb
Version:   0.0.2
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

Requires: mariadb
Requires: mariadb-server
Requires: perl-DBD-MySQL
Requires: perl-GRNOC-Config
Requires: perl-GRNOC-Log
Requries: perl-MIME-Lite-TT
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

%{__install} -d -p %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/GWS.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS.pm

%{__install} -d -p %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/Result.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Result.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/User.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/User.pm
%{__install} lib/GRNOC/NetSage/ResourceDB/DataService/Util.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Util.pm

%{__install} -d -p %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS
%{__install} lib/GRNOC/NetSage/ResourceDB/GWS/User.pm %{buildroot}%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/User.pm

# HTTP and web files
%{__install} -d -p %{buildroot}%{_datadir}/resourcedb/www/static

cp -ar www/static/* %{buildroot}%{_datadir}/resourcedb/www/static

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
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Result.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/User.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/DataService/Util.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS.pm
%{perl_vendorlib}/GRNOC/NetSage/ResourceDB/GWS/User.pm

%{_datadir}/resourcedb/www/static/

%{_sysconfdir}/grnoc/netsage/resourcedb/resourcedb.sql

%{_bindir}/resourcedb-init-db
%{_bindir}/resourcedb-update-db
