%global _hardened_build 1

Name:           doxyparse
Version:        1.5.9
Release:        1%{?dist}
Summary:        Multi-language source code analyzer

Group:          Development/Languages
License:        GPLv2
URL:            https://github.com/terceiro/doxyparse
Source0:        https://analizo.github.io/download/doxyparse_%{version}.orig.tar.gz
Patch100:       0001-Fix-compilation-errors-in-g-4.9.patch 
Patch101:       0002-Use-C-XX-FLAGS-from-environment-in-configure.patch

BuildRequires:  flex
BuildRequires:  bison
BuildRequires:  libstdc++-devel
BuildRequires:  perl

%description
doxyparse builts on doxygen's great source code parsing infrastructure and
provides a command-line tool that can be used to obtain informatin from source
code, such as:

* which functions/methods and variables/attributes a module/class contains
* which functions/methods calls/uses which functions/methods/variables
* etc

doxyparses's main goal is to be used by higher-level source code analyzis
tools.

%prep
%setup -q -n doxyparse-%{version}
%patch100 -p1
%patch101 -p1
CFLAGS="${CFLAGS:-%optflags}" CXXFLAGS="${CXXFLAGS:-%optflags}" ./configure --prefix %{_prefix} --with-doxyparse

%build
%make_build

%install
%make_install

# We don't want the actual doxygen executable

rm %{buildroot}%{_prefix}/bin/doxygen
rm %{buildroot}%{_prefix}/man/man1/doxygen*

%if "%{_prefix}/man/man1" != "%{_mandir}/man1"
  %{__mkdir_p} %{buildroot}%{_mandir}/man1
  mv %{buildroot}%{_prefix}/man/man1/* %{buildroot}%{_mandir}/man1
%endif

%if "%{_prefix}/bin" != "%{_bindir}"
  %{__mkdir_p} %{buildroot}%{_bindir}
  mv %{buildroot}%{_prefix}/bin/* %{buildroot}%{_bindir}
%endif

%files

%doc INSTALL LANGUAGE.HOWTO PLATFORMS README
%{_bindir}/*
%{_mandir}/man1/*

%changelog

* Thu Mar 19 2015 Daniel Miranda
- Initial Packaging
