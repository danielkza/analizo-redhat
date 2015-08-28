%global _hardened_build 1
%define analizo_1_18_0_or_older 0

Name:           analizo
Version:        1.18.1
Release:        1%{?dist}
Summary:        Analizo is a free, multi-language, extensible source code analysis and visualization toolkit

Group:          Development/Languages
License:        GPLv3
URL:            http://www.analizo.org

%if %{analizo_1_18_0_or_older}
Source0:        http://analizo.org/download/analizo_%{version}.tar.gz
%else
Source0:        http://analizo.org/download/analizo_%{version}.tar.xz
%endif

BuildArch:      noarch

BuildRequires:  git
BuildRequires:  man
BuildRequires:  sloccount
BuildRequires:  doxyparse
BuildRequires:  clang-analyzer
BuildRequires:  ruby(release)
BuildRequires:  rubygem-rspec
BuildRequires:  rubygem-rake
BuildRequires:  rubygem-cucumber
BuildRequires:  perl(Archive::Extract)
BuildRequires:  perl(ExtUtils::MakeMaker)
BuildRequires:  perl(File::LibMagic)
BuildRequires:  perl(File::ShareDir::Install)
BuildRequires:  perl(File::Slurp)
BuildRequires:  perl(Method::Signatures)
BuildRequires:  perl(Test::BDD::Cucumber)
BuildRequires:  perl(Test::Class)
BuildRequires:  perl(Test::Exception)
BuildRequires:  perl(Test::MockModule)
BuildRequires:  perl(Test::MockObject)
# Same as runtime requirements, we need them to run the tests
BuildRequires:  perl(App::Cmd)
BuildRequires:  perl(Class::Accessor)
BuildRequires:  perl(Class::Inspector)
BuildRequires:  perl(DBD::SQLite)
BuildRequires:  perl(DBI)
BuildRequires:  perl(CHI)
BuildRequires:  perl(Digest::SHA)
BuildRequires:  perl(File::Copy::Recursive)
BuildRequires:  perl(File::HomeDir)
BuildRequires:  perl(File::Share)
BuildRequires:  perl(File::ShareDir)
BuildRequires:  perl(FindBin::libs)
BuildRequires:  perl(Graph)
BuildRequires:  perl(Graph::Writer::Dot) 
BuildRequires:  perl(Graph::Writer::DSM) >= 0.005
BuildRequires:  perl(JSON)
BuildRequires:  perl(List::Compare)
BuildRequires:  perl(Mojolicious)
BuildRequires:  perl(Statistics::Descriptive)
BuildRequires:  perl(Term::ProgressBar)
BuildRequires:  perl(YAML)
BuildRequires:  perl(YAML::Tiny)
BuildRequires:  perl(ZeroMQ)

Requires:       sloccount
Requires:       doxyparse
Requires:       clang-analyzer
Requires:       perl(:MODULE_COMPAT_%(eval "`%{__perl} -V:version`"; echo $version))
Requires:       perl(App::Cmd)
Requires:       perl(Class::Accessor)
Requires:       perl(Class::Inspector)
Requires:       perl(DBD::SQLite)
Requires:       perl(DBI)
Requires:       perl(CHI)
Requires:       perl(Digest::SHA)
Requires:       perl(File::Copy::Recursive)
Requires:       perl(File::HomeDir)
Requires:       perl(File::Share)
Requires:       perl(File::ShareDir)
Requires:       perl(FindBin::libs)
Requires:       perl(Graph)
Requires:       perl(Graph::Writer::Dot) 
Requires:       perl(Graph::Writer::DSM) >= 0.005
Requires:       perl(JSON)
Requires:       perl(List::Compare)
Requires:       perl(Mojolicious)
Requires:       perl(Statistics::Descriptive)
Requires:       perl(Term::ProgressBar)
Requires:       perl(YAML)
Requires:       perl(YAML::Tiny)
Requires:       perl(ZeroMQ)

%description
Analizo is a free, multi-language, extensible source code analysis and
visualization toolkit. It supports the extraction and calculation of a fair
number of source code metrics, generation of dependency graphs, and software
evolution analysis. 

%prep   
%setup -q -n analizo

%build
%{__perl} Makefile.PL INSTALLDIRS=vendor
make %{?_smp_mflags}

%install
make pure_install DESTDIR=%{buildroot}
find %{buildroot} -type f -name .packlist -exec rm -f {} \;
find %{buildroot} -depth -type d -exec rmdir {} 2>/dev/null \;

mkdir -p %{buildroot}%{_sysconfdir}/bash_completion.d
install -pm 644 share/bash-completion/analizo %{buildroot}%{_sysconfdir}/bash_completion.d/analizo

%{_fixperms} %{buildroot}/*

%check
# PATH="$PATH:%{buildroot}%{_bindir}" PERL5LIB="$PERL5LIB:$PWD/lib" rake

%files
%defattr(-,root,root,-)
%doc AUTHORS README.md INSTALL.md PROFILING.md RELEASE.md
%{perl_vendorlib}/*
%{_bindir}/analizo
%{_mandir}/man1/*
%{_sysconfdir}/bash_completion.d

%changelog
* Thu Mar 19 2015 Daniel Miranda
- Initial Packaging
