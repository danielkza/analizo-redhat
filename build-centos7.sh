#!/bin/sh

set -e

fedora_git_base="git://pkgs.fedoraproject.org/"
rpm_dir="$PWD/rpms"

mkdir -p rpms deps-dist
pushd deps-dist

packages=$(cat <<EOF
perl-IO-TieCombine
perl-App-Cmd
perl-CHI
perl-Graph
perl-Mojolicious
perl-Statistics-Descriptive
perl-Term-ProgressBar
perl-ZeroMQ
EOF
)

cpan_packages=$(cat <<EOF
ExtUtils::MakeMaker
Fatal
File::LibMagic
Method::Signatures
String::RewritePrefix
Digest::JHash
Hash::MoreUtils
Moo
MooX::Types::MooseLike
MooX::Types::MooseLike::Base
MooX::Types::MooseLike::Numeric
String::RewritePrefix
Test::Log::Dispatch
Test::TempDir
EOF
)

sudo yum install -y git make automake gcc gcc-c++ file-devel rpmdevtools


export PERL_CPANM_OPT="--mirror http://backpan.perl.org/"
cpanm $cpan_packages

IFS=$'\n'
for package in $packages; do
    [ -e "$package" ] || git clone "${fedora_git_base}${package}.git"
    pushd "$package"

    git checkout f19
    sed -i 's|http://search.cpan.org/CPAN|http://backpan.perl.org|' *.spec
    spectool -g *.spec

    sudo mock --buildsrpm --spec *.spec --sources . --resultdir "$rpm_dir"

    popd
done
unset IFS

popd
pushd deps

IFS=$'\n'
for package in */; do
    pushd "$package"
    
    sed -i 's|http://search.cpan.org/CPAN|http://backpan.perl.org|' *.spec
    spectool -g *.spec

    sudo mock --buildsrpm --spec *.spec --sources . --resultdir "$rpm_dir"

    popd
done
unset IFS
