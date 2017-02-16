Summary:   NetSage Resource Database
Name:      resourcedb
Version:   0.0.1
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

%description
NetSage Resource Database (Science Registry)

%prep
%setup -q -n resourcedb-%{version}

%build
%{__perl} Makefile.PL PREFIX="%{buildroot}%{_prefix}" INSTALLDIRS="vendor"
make

%install
%{__install} -d -p %{buildroot}%{_datadir}/resourcedb/www/static

cp -ar www/static/* %{buildroot}%{_datadir}/resourcedb/www/static

%clean
rm -rf $RPM_BUILD_ROOT

%files
%{_datadir}/resourcedb/www/static/
