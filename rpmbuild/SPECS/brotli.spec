Summary: Brotli
Name: brotli
Version: 0.3.0
Release: 1%{?dist}
URL: https://github.com/google/brotli
Source0: https://github.com/google/brotli/v%{version}.tar.gz
License: MIT
Group: Applications/Archiving
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root
%if 0%{?rhel} >= 7
BuildRequires: make gcc-c++
%else
BuildRequires: make devtoolset-3-gcc-c++
%endif

%description
Brotli compression tools from Google

%prep
%setup -q

%build
cd tools
make %{?_smp_mflags}

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT/%{_bindir}
install -m 755 tools/bro $RPM_BUILD_ROOT/%{_bindir}/bro

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%{_bindir}/bro

%changelog
* Wed Feb 24 2016 AIZAWA Hina <hina@bouhime.com> - 0.3.0-1
- v0.3.0
